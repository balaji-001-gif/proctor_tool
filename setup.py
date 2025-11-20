from setuptools import setup, find_packages

setup(
    name="proctor_tool",
    version="0.1.0",
    description="Proctoring tool for Frappe/LMS",
    author="Your Name",
    packages=find_packages(),
    install_requires=["frappe","requests"],
    zip_safe=False,
)
