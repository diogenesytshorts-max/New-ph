from google import genai
import sys
import time

try:
    client = genai.Client()
except Exception as e:
    print("Error: API Key set nahi hai ya galat hai.")
    sys.exit(1)

# Yahan humne model 3.7 se badal kar 3.5 kar diya hai (No server load issues)
chat = client.chats.create(model="gemini-3.5-flash")

print("==================================================")
print("🤖 Gemini 3.5 Chatbot shuru ho gaya hai!")
print("❌ Chat band karne ke liye 'exit' ya 'quit' type karein.")
print("==================================================\n")

while True:
    try:
        user_input = input("Aap 🧑‍💻: ")
    except EOFError:
        break
    
    if user_input.lower() in ['exit', 'quit']:
        print("Chat band ho rahi hai. Alvida! 👋")
        break
        
    if not user_input.strip():
        continue

    # Agar server busy ho, toh 3 baar try karega
    max_retries = 3
    for attempt in range(max_retries):
        try:
            response = chat.send_message(user_input)
            print(f"Gemini 🤖: {response.text}\n")
            break 
            
        except Exception as e:
            error_msg = str(e)
            # Check karega ki kya error 503 (Server Busy) hai
            if "503" in error_msg or "high demand" in error_msg:
                if attempt < max_retries - 1:
                    print("⏳ Google ka server abhi thoda busy hai. 2 second mein dobara try kar raha hoon...")
                    time.sleep(2)
                else:
                    print("❌ Server par abhi bohot zyada load hai. Kripya thodi der baad dobara sawal poochein.\n")
            else:
                print(f"❌ Kuch aur galat ho gaya! Error: {e}\n")
                break
