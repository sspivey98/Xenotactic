# server.py
from http.server import HTTPServer, SimpleHTTPRequestHandler

WASM_EXTENSIONS = ('.wasm', '.js', '.love', '.data')

class WasmHandler(SimpleHTTPRequestHandler):
    def end_headers(self):
        # Only apply to files that need it
        if self.path.endswith(WASM_EXTENSIONS):
            self.send_header("Cross-Origin-Opener-Policy", "same-origin")
            self.send_header("Cross-Origin-Embedder-Policy", "require-corp")
            self.send_header("Cross-Origin-Resource-Policy", "same-origin")
        super().end_headers()

HTTPServer(("0.0.0.0", 8000), WasmHandler).serve_forever()
