#!/bin/bash

# Create necessary directories
mkdir -p proctor_tool/proctor_tool/doctype/proctor_session
mkdir -p proctor_tool/public/js

# Write proctor_session.json
cat > proctor_tool/proctor_tool/doctype/proctor_session/proctor_session.json << 'EOF'
{
  "doctype":"DocType",
  "name":"Proctor Session",
  "module":"Proctor Tool",
  "custom":true,
  "fields":[
    {"fieldname":"student","label":"Student","fieldtype":"Link","options":"User","reqd":1},
    {"fieldname":"quiz_submission","label":"Quiz Submission","fieldtype":"Link","options":"LMS Quiz Submission"},
    {"fieldname":"quiz","label":"Quiz","fieldtype":"Link","options":"LMS Quiz"},
    {"fieldname":"status","label":"Status","fieldtype":"Select","options":"Running\nCompleted\nFlagged\nCancelled","default":"Running"}
  ],
  "permissions":[
    {"role":"System Manager","read":1,"write":1},
    {"role":"Instructor","read":1},
    {"role":"Student","read":1}
  ]
}
EOF

# Write hooks.py
cat > proctor_tool/hooks.py << 'EOF'
from . import __version__

doc_events = {
    "LMS Quiz Submission": {
        "after_insert": "proctor_tool.api.after_session_create",
        "on_submit": "proctor_tool.api.on_session_submit"
    }
}

doctype_js = {
    "LMS Quiz": "public/js/proctor_quiz.js"
}

web_include_js = "proctor_quiz.js"

app_name = "proctor_tool"
app_title = "Proctor Tool"
app_publisher = "You"
app_description = "Lightweight proctoring integration for Frappe LMS"
app_icon = "octicon octicon-device-camera"
app_color = "blue"
app_version = __version__
EOF

# Write api.py
cat > proctor_tool/api.py << 'EOF'
import frappe
from frappe.utils import now
from werkzeug.utils import secure_filename
import base64
from frappe.utils.file_manager import save_file

def after_session_create(doc, method):
    """Create a Proctor Session when an LMS Quiz Submission is created."""
    if not doc.quiz:
        return

    proctor_session = frappe.get_doc({
        "doctype": "Proctor Session",
        "student": doc.member, # LMS Quiz Submission uses 'member' for the user
        "quiz_submission": doc.name,
        "quiz": doc.quiz,
        "status": "Running"
    })
    proctor_session.insert(ignore_permissions=True)

def on_session_submit(doc, method):
    """Mark Proctor Session as Completed when LMS Quiz Submission is submitted."""
    sessions = frappe.get_all("Proctor Session", filters={"quiz_submission": doc.name})
    for session in sessions:
        frappe.db.set_value("Proctor Session", session.name, "status", "Completed")

@frappe.whitelist(allow_guest=True)
def upload_evidence(session, filename=None, content=None):
    if not frappe.db.exists("Proctor Session", session):
        frappe.throw("Invalid session")
    filename = secure_filename(filename or "evidence.png")
    if content:
        filedata = base64.b64decode(content)
        fn = save_file(filename, filedata, "Proctor Session", session, is_private=1)
        return {"file_url": fn.file_url}
    frappe.throw("No content")

@frappe.whitelist()
def get_session_for_quiz(quiz):
    """Get the active Proctor Session for a given quiz."""
    submission = frappe.db.get_value("LMS Quiz Submission", 
        {"quiz": quiz, "member": frappe.session.user, "docstatus": 0}, "name")
    
    if not submission:
        return None
        
    return frappe.db.get_value("Proctor Session", {"quiz_submission": submission}, "name")
EOF

# Write proctor_quiz.js
cat > proctor_tool/public/js/proctor_quiz.js << 'EOF'
frappe.ready(function() {
    // Check if we are on a quiz page
    // URL pattern: /lms/course/<course>/quiz/<quiz>
    if (window.location.pathname.includes("/quiz/")) {
        console.log("Proctor Tool: Quiz page detected");
        initProctoring();
    }
});

function initProctoring() {
    // Get quiz name from URL
    // Assuming the last part of the path is the quiz name
    const parts = window.location.pathname.split("/");
    const quizName = decodeURIComponent(parts[parts.length - 1]);

    if (!quizName) return;

    frappe.call({
        method: "proctor_tool.api.get_session_for_quiz",
        args: { quiz: quizName },
        callback: function(r) {
            if (r.message) {
                console.log("Proctor Session found:", r.message);
                startMonitoring(r.message);
            } else {
                console.log("Proctor Tool: No active session found for this quiz.");
            }
        }
    });
}

function startMonitoring(sessionName) {
    // Request camera
    navigator.mediaDevices.getUserMedia({ video: true })
        .then(stream => {
            console.log("Proctor Tool: Camera access granted");
            const video = document.createElement('video');
            video.srcObject = stream;
            video.play();
            
            // Capture immediately and then every 30 seconds
            captureAndUpload(video, sessionName);
            setInterval(() => {
                captureAndUpload(video, sessionName);
            }, 30000);
        })
        .catch(err => {
            console.error("Proctor Tool: Camera access denied", err);
            frappe.msgprint(__("Please allow camera access to continue the quiz. Proctoring is required."));
        });
}

function captureAndUpload(video, sessionName) {
    const canvas = document.createElement('canvas');
    canvas.width = video.videoWidth;
    canvas.height = video.videoHeight;
    canvas.getContext('2d').drawImage(video, 0, 0);
    const dataURL = canvas.toDataURL('image/jpeg', 0.7); // Quality 0.7
    const content = dataURL.split(',')[1]; // remove prefix

    frappe.call({
        method: "proctor_tool.api.upload_evidence",
        args: {
            session: sessionName,
            content: content,
            filename: "snap_" + Date.now() + ".jpg"
        },
        silent: true,
        callback: function(r) {
            console.log("Proctor Tool: Evidence uploaded");
        }
    });
}
EOF

echo "Changes applied successfully."
