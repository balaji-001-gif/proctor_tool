from setuptools import setup, find_packages

setup(
    name="proctor_tool",
    version="0.1.0",
    description="Proctoring integration for Frappe LMS",
    author="Attri",
    author_email="support@attri.com",
    packages=find_packages(),
    install_requires=["frappe", "requests"],
    zip_safe=False,
)
