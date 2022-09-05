from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import datetime

import logging
import os

import inference

# Init
logger = logging.getLogger(__name__)
app = FastAPI()
app.include_router(inference.router)

# Logging Setting
LOG_LEVEL = logging.getLevelName(os.environ.get("LOG_LEVEL", "DEBUG"))
logging.root.setLevel(LOG_LEVEL)

# CORS setting with accept all income url
origins = [
    "*"
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# Basic Example for API call
@app.get("/")
def root():
    logger.debug("DEBUG Message")
    logger.info("INFO Message")
    logger.error("ERROR Message")
    # FastAPI will auto turn the response into JSON format.
    return {
        "now": datetime.datetime.now()
    }

