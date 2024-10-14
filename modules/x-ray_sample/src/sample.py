from logging import getLogger
import json

logger = getLogger(__name__)

def handler(data, context):
    logger.info(f"start handler {data=} {context=}")
    data_list = [ json.loads(json.loads(r["body"])["Message"]) for r in data["Records"] ]

    for d in data_list:
      n = d["n"]
      if n % 2 == 0:
          logger.info(f"{n} is even")
      else:
          logger.info(f"{n} is odd")

def _data2rec(data):
    return {
        "Records":[{
            "body": json.dumps({
                "Message": json.dumps(data)
            })
        }]
    }


if __name__ == "__main__":
    import logging
    import json
    ch = logging.StreamHandler()
    logger.addHandler(ch)
    logger.setLevel(logging.INFO)

    handler(_data2rec({"n": 42}), {})
