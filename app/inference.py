import os
import boto3
from pydantic import BaseModel
from typing import List

import tensorflow as tf
from fastapi import APIRouter, HTTPException

router = APIRouter()


class ItemList(BaseModel):
    title_list: List[str]


bucket_name = 'jj-model'
model_folder_name = 'universal-sentence-encoder'


def download_directory_from_s3(bucket_name, remote_directory_name):
    s3_resource = boto3.resource('s3')
    bucket = s3_resource.Bucket(bucket_name)
    for obj in bucket.objects.filter(Prefix=remote_directory_name):
        if not os.path.exists(os.path.dirname(obj.key)):
            os.makedirs(os.path.dirname(obj.key))
        bucket.download_file(obj.key, obj.key)


download_directory_from_s3(bucket_name, model_folder_name)


def load_model(model_folder_name):
    encoder = tf.keras.models.load_model(model_folder_name)
    return encoder


encoder = load_model(model_folder_name)


@router.post("/sentence_encoder")
def sentence_encoder(item: ItemList):
    try:
        score_list = encoder(item.title_list).numpy().tolist()
        return [{
            title: score
        } for title, score in zip(item.title_list, score_list)]
    except Exception as e:
        raise HTTPException(500, "sentence encoder fail :{}".format(e))


