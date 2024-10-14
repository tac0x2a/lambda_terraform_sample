from logging import getLogger
from sympy import sieve

logger = getLogger(__name__)

def handler(data, context):
    logger.info("start handler", extra={"data": data, "context": context})
    n = data["n"]
    if n in sieve:
        logger.info(f"{n} is prime")
    else:
        logger.info(f"{n} is not prime")


if __name__ == "__main__":
    import logging
    ch = logging.StreamHandler()
    logger.addHandler(ch)
    logger.setLevel(logging.INFO)

    handler({"n": 42}, {})
