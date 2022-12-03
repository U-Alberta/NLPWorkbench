FROM python:3.7
WORKDIR /app
RUN mkdir /app/cache && mkdir /app/re_log && mkdir /app/runs
COPY requirements.txt .
RUN --mount=type=cache,target=/root/.cache/pip \
    pip3 install --use-feature=fast-deps -r requirements.txt && \
    python3 -m spacy download en_core_web_lg
ENV PYTHONUNBUFFERED=TRUE
WORKDIR /app
COPY . .
CMD ["python3", "run.py"]