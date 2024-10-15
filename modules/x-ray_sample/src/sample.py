from logging import getLogger
import json
from sympy import sieve

logger = getLogger(__name__)


def handler(data, context):
    # import os
    # logger.info(f"{os.listdir('/opt')=}")
    # if os.path.isdir("/opt/python"):
    #     logger.info(f"{os.listdir('/opt/python')=}")

    data_list = [json.loads(json.loads(r["body"])["Message"]) for r in data["Records"]]
    logger.info(f"{data_list=}")

    for d in data_list:
        n = d["n"]
        if n in sieve:
            logger.info(f"{n} is prime")
        else:
            logger.info(f"{n} is NOT prime")


if __name__ == "__main__":
    import logging
    import json

    def _data2rec(data):
        return {"Records": [{"body": json.dumps({"Message": json.dumps(data)})}]}

    ch = logging.StreamHandler()
    logger.addHandler(ch)
    logger.setLevel(logging.INFO)

    handler(_data2rec({"n": 42}), {})
