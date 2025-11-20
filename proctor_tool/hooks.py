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
