from flask import Flask, make_response
import os
app = Flask(__name__)

@app.route('/')
def hello():
    return 'Hello, Botit!'

@app.route('/<page_name>')
def other_page(page_name):
    response = make_response('The page named %s does not exist.' \
                             % page_name, 404)
    return response

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 9999))
    app.run(debug=True, host='0.0.0.0', port=port)
