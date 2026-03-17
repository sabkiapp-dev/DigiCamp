#!/usr/bin/env python3
"""
Custom HTTP server for DigiCampInterface that handles client-side routing (SPA).
Serves index.html for all routes that don't match a file.
"""
import http.server
import socketserver
import os

PORT = int(os.environ.get('PORT', 8080))
DIRECTORY = os.environ.get('DIRECTORY', '/opt/DigiCamp/digicamp_interface')

class FlutterHTTPRequestHandler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=DIRECTORY, **kwargs)

    def end_headers(self):
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Cache-Control', 'no-cache')
        super().end_headers()

    def do_GET(self):
        path = self.translate_path(self.path)

        # If path doesn't exist or is a directory, serve index.html
        if not os.path.exists(path) or os.path.isdir(path):
            if '.' not in os.path.basename(self.path):
                self.path = '/index.html'

        return super().do_GET()

    def guess_type(self, path):
        if path.endswith('.js'):
            return 'application/javascript'
        if path.endswith('.wasm'):
            return 'application/wasm'
        if path.endswith('.json'):
            return 'application/json'
        return super().guess_type(path)

if __name__ == "__main__":
    os.chdir(DIRECTORY)
    with socketserver.TCPServer(("", PORT), FlutterHTTPRequestHandler) as httpd:
        print(f"Serving DigiCampInterface at http://0.0.0.0:{PORT}")
        httpd.serve_forever()
