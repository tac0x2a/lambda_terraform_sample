import logging
import json

def handler(event, context):
  logging.warning(f"Event: {event}")
  logging.warning(f"Context: {context}")
