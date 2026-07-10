# Use an official, lightweight Python runtime
FROM python:3.10-slim

# Set working directory inside the container
WORKDIR /app

# Install Flask
RUN pip install --no-cache-dir flask

# Create a simple inline Python voting application
RUN echo 'from flask import Flask, render_template_string, request\n\
app = Flask(__name__)\n\
votes = {"Option Team A": 0, "Option Team B": 0}\n\
HTML = """\n\
<h1>Vote App</h1>\n\
<form method="POST"><button name="vote" value="Option Team A">Option Team A ({{a}})</button></form>\n\
<form method="POST"><button name="vote" value="Option Team B">Option Team B ({{b}})</button></form>\n\
"""\n\
@app.route("/", methods=["GET", "POST"])\n\
def index():\n\
    if request.method == "POST": votes[request.form["vote"]] += 1\n\
    return render_template_string(HTML, a=votes["Option Team A"], b=votes["Option Team B"])\n\
if __name__ == "__main__": app.run(host="0.0.0.0", port=5000)\n\
' > app.py

# Expose port 5000 for the app
EXPOSE 5000

# Run the app
CMD ["python", "app.py"]