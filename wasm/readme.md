docker build -t xenotactic-wasm .
docker run -d --restart unless-stopped --name=xenotactic-wasm -p 8000:8000 xenotactic-wasm
