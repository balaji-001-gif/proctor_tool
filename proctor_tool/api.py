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
