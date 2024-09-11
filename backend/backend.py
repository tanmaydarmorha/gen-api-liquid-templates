from flask import Flask, request, jsonify
import os
import google.generativeai as genai
import re

# Set the application name
app = Flask(__name__, instance_relative_config=True)

# Configure Gemini API key
genai.configure(api_key=os.environ["GEMINI_API_KEY"])

# Define Gemini model
generation_config = {
    "temperature": 1,
    "top_p": 0.95,
    "top_k": 64,
    "max_output_tokens": 8192,
    "response_mime_type": "text/plain",
}

model = genai.GenerativeModel(
    model_name="gemini-1.5-flash",
    generation_config=generation_config,
)

@app.route('/generateTemplates', methods=['POST'])
def generate_templates():
    """
    Endpoint for generating templates using Gemini.

    Request Body:
    {
        "inputJson": { ... },
        "mappingRules": { ... }
    }

    Returns:
    {
        "template": "... (Liquid template)"
    }
    """

    data = request.get_json()
    input_json = data.get('inputJson')
    mapping_rules = data.get('mappingRules')

    # Construct prompt for Gemini
    prompt = [
        "response should only contain liquid template, no explanation needed",
        "input: if input is json array",
        "output: response should be a fhir bundle liquid template",
        "input: if input is json object",
        "output: response should be a fhir resource liquid template",
        "input: {} \n\nI have this json, I want a liquid template which converts this to following FHIR json\n\n {}",
        "output: ",
    ]

    # Replace placeholders with actual data
    prompt[5] = prompt[5].format(str(input_json), str(mapping_rules))

    # Call Gemini model
    response = model.generate_content(prompt)

    # Clean up the template using regular expressions
    template = re.sub(r'```liquid\n|\n```', '', response.text)

    chat_session = model.start_chat(
        history=[
            {
                "role": "user",
                "parts": [
                    "I have this liquid template {}".format(template),
                ],
            }
        ]
    )

    response = chat_session.send_message("I want you to add null checks in this template, for example if email is missing, it should not populate the inner json element. Response should only have the liquid template, no explanation should be there")

    template = re.sub(r'```liquid\n|\n```', '', response.text)

    # Return the generated liquid template as a string
    return jsonify({"template": template})

if __name__ == '__main__':
    app.run(debug=True)