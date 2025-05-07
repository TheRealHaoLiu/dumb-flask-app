from flask import Flask, request, jsonify
import logging
import sys

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s [%(levelname)s] %(message)s',
    handlers=[logging.StreamHandler(sys.stdout)]
)
logger = logging.getLogger(__name__)

app = Flask(__name__)

@app.route('/ping/', methods=['GET'])
def ping():
    logger.info("Received ping request")
    return jsonify({"status": "ok"})

@app.route('/', defaults={'path': ''})
@app.route('/<path:path>', methods=['GET', 'POST', 'PUT', 'DELETE', 'PATCH'])
def catch_all(path):
    # Log the request details
    logger.info(f"Received {request.method} request to /{path}")
    logger.info(f"Headers: {dict(request.headers)}")

    if request.data:
        logger.info(f"Body: {request.data.decode('utf-8')}")

    if request.args:
        logger.info(f"Query params: {dict(request.args)}")

    # Return a JSON response with the request details
    response = {
        'message': 'Request received and logged',
        'method': request.method,
        'path': path,
        'headers': dict(request.headers),
        'query_params': dict(request.args)
    }

    if request.is_json:
        response['json_body'] = request.json

    return jsonify(response)

if __name__ == '__main__':
    logger.info("Example Service starting up...")
    app.run(host='0.0.0.0', port=5000)
