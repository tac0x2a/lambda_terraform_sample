import logging

logger = logging.getLogger(__name__)
logger.setLevel("INFO")


def handler(event, context):
    logging.info(f"Event: {event}")
    logging.info(f"Context: {context}")

    return 42
