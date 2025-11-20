frappe.ready(function () {
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
        callback: function (r) {
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
        callback: function (r) {
            console.log("Proctor Tool: Evidence uploaded");
        }
    });
}
