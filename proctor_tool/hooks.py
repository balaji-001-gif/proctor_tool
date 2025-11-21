from . import __version__

app_name = "proctor_tool"
app_title = "Proctor Tool"
app_publisher = "Attri"
app_description = "Proctoring integration for Frappe LMS"
app_icon = "octicon octicon-device-camera"
app_color = "blue"
app_email = "support@attri.com"
app_license = "MIT"

# Includes in <head>
# ------------------

# include js, css files in header of desk.html
# app_include_css = "/assets/proctor_tool/css/proctor_tool.css"
# app_include_js = "/assets/proctor_tool/js/proctor_tool.js"

# include js, css files in header of web template
# web_include_css = "/assets/proctor_tool/css/proctor_tool.css"
web_include_js = "proctor_quiz.js"

# DocEvents
# ------------------
# On submission of LMS Quiz
doc_events = {
    "LMS Quiz Submission": {
        "after_insert": "proctor_tool.api.after_session_create",
        "on_submit": "proctor_tool.api.on_session_submit"
    }
}

# Doctype JS
# ------------------
doctype_js = {
    "LMS Quiz": "public/js/proctor_quiz.js"
}
