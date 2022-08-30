#!/usr/bin/python
import os
import json
import boto3
import tempfile
import urllib2

import numpy as np
from collections import namedtuple
from flask import Flask, Response
from flask import request
from flask import jsonify
import tensorflow as tf

Batch = namedtuple('Batch', ['data'])

#download model files
f_params = 'resnet-18-0000.params'
f_symbol = 'resnet-18-symbol.json'

bucket_name = 'jj-model'
model_folder_name = 'universal-sentence-encoder_4'
s3 = boto3.resource('s3')
s3_client = boto3.client('s3')

def download_directory_from_s3(bucket_name, remote_directory_name):
    s3_resource = boto3.resource('s3')
    bucket = s3_resource.Bucket(bucket_name)
    for obj in bucket.objects.filter(Prefix = remote_directory_name):
        if not os.path.exists(os.path.dirname(obj.key)):
            os.makedirs(os.path.dirname(obj.key))
        bucket.download_file(obj.key, obj.key) # save to same path

download_directory_from_s3(bucket_name, model_folder_name)

def load_model():
     """
     Load model checkpoint from file.
     :return: (arg_params, aux_params)
     arg_params : dict of str to NDArray
         Model parameter, dict of name to NDArray of net's weights.
     aux_params : dict of str to NDArray
         Model parameter, dict of name to NDArray of net's auxiliary states.
     """

     encoder = tf.keras.models.load_model(model_folder_name)
     return encoder



def predict(url, mod, synsets):
     req = urllib2.urlopen(url)
     arr = np.asarray(bytearray(req.read()), dtype=np.uint8)
     cv2_img = cv2.imdecode(arr, -1)
     img = cv2.cvtColor(cv2_img, cv2.COLOR_BGR2RGB)
     if img is None:
         return None
     img = cv2.resize(img, (224, 224))
     img = np.swapaxes(img, 0, 2)
     img = np.swapaxes(img, 1, 2)
     img = img[np.newaxis, :]

     mod.forward(Batch([mx.nd.array(img)]))
     prob = mod.get_outputs()[0].asnumpy()
     prob = np.squeeze(prob)

     a = np.argsort(prob)[::-1]
     out = ''
     for i in a[0:5]:
         out += 'probability=%f, class=%s' %(prob[i], synsets[i])
     out += "\n"
     return out

with open('/app/synset.txt', 'r') as f:
     synsets = [l.rstrip() for l in f]

app = Flask(__name__)

@app.route('/')
def index():
    resp = Response(response="Success",
         status=200, \
         mimetype="application/json")
    return (resp)

@app.route('/image')
def image():
    print 'api'
    url = request.args.get('image')
    print url


    sym, arg_params, aux_params = load_model(f_symbol_file.name, f_params_file.name)
    mod = mx.mod.Module(symbol=sym, context=mx.cpu())
    mod.bind(for_training=False, data_shapes=[('data', (1,3,224,224))])
    mod.set_params(arg_params, aux_params)

    labels = predict(url, mod, synsets)

    resp = Response(response=labels,
    status=200, \
    mimetype="application/json")

    return(resp)

if __name__ == '__main__':
    app.run('0.0.0.0', debug=True)
