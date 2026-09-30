import gradio as gr
from google import genai
import os

# API Key check karein
if not os.environ.get("GOOGLE_API_KEY"):
    print("Error: GOOGLE_API_KEY set nahi hai.")
    exit(1)

client = genai.Client()

# Gemini 3.5 Flash use kar rahe hain taaki server error na aaye
chat = client.chats.create(model="gemini-3.5-flash")

# Chat function jo user ka message lega aur Gemini ka jawab dega
def chat_with_gemini(message, history):
    try:
        response = chat.send_message(message)
        return response.text
    except Exception as e:
        return f"Kuch galat ho gaya: {e}"

# Gradio ka bana-banaya Chat Interface
demo = gr.ChatInterface(
    fn=chat_with_gemini,
    title="🤖 Mera Personal Gemini Chatbot",
    description="Yeh chatbot GitHub Codespace par chal raha hai!",
    theme="soft"
)

# Server start karein (0.0.0.0 zaroori hai taaki Codespace isko dekh sake)
demo.launch(server_name="0.0.0.0", server_port=7860)
