from flask import Flask, jsonify
from prometheus_flask_exporter import PrometheusMetrics

app = Flask(__name__)

# Initialize Prometheus metrics
metrics = PrometheusMetrics(app)

# Expose default app metrics
@app.route('/')
def home():
    return jsonify(message="Hello, Kubernetes!")

# Custom metric (e.g., count requests to `/api`)
metrics.info('app_info', 'Application info', version='1.0.0')

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
