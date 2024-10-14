from logging import getLogger
import json

logger = getLogger(__name__)

def handler(data, context):
    data_list = [ json.loads(json.loads(r["body"])["Message"]) for r in data["Records"] ]
    logger.info(f"{data_list=}")

    for d in data_list:
      n = d["n"]
      if n % 2 == 0:
          logger.info(f"{n} is even")
      else:
          logger.info(f"{n} is odd")

if __name__ == "__main__":
    import logging
    import json

    def _data2rec(data):
      return {
          "Records":[{
              "body": json.dumps({
                  "Message": json.dumps(data)
              })
          }]
      }

    ch = logging.StreamHandler()
    logger.addHandler(ch)
    logger.setLevel(logging.INFO)

    handler(_data2rec({"n": 42}), {})
