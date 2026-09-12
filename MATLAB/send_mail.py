import smtplib
import sys
from email.message import EmailMessage

def send_report(to_email, subject, body, attachment_path):
    # Sender details
    sender_email = "telemedicine.neuroforge@outlook.com"
    app_password = "biyjwwmezdqjwiqx"  # <-- Yahan apna personal Outlook password daalo

    msg = EmailMessage()
    msg['Subject'] = subject
    msg['From'] = sender_email
    msg['To'] = to_email
    msg.set_content(body)

    if attachment_path:
        try:
            with open(attachment_path, 'rb') as f:
                file_data = f.read()
                file_name = f.name
            msg.add_attachment(file_data, maintype='image', subtype='png', filename=file_name)
        except Exception as e:
            print(f"Attachment Error: {e}")

    try:
        # Outlook specific server connection with TLS
        server = smtplib.SMTP('smtp-mail.outlook.com', 587)
        server.ehlo()
        server.starttls()
        server.login(sender_email, app_password)
        server.send_message(msg)
        server.quit()
        print("SUCCESS")
    except Exception as e:
        print(f"ERROR: {e}")

if __name__ == "__main__":
    send_report(sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4])