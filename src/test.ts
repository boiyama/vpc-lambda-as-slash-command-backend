import assert from "assert";
import { handler } from "./main";

const event = {
  Records: [
    {
      body:
        "token=xxxxxxxxxxxxxxxxxxxxxxxx&team_id=XXXXXXXXX&team_domain=xxxxx&channel_id=XXXXXXXXX&channel_name=xxxxxxxxxxxx&user_id=XXXXXXXXX&user_name=xxxxxxxxxxxx&command=%2Ffoo&text=&response_url=https%3A%2F%2Fhooks.slack.com%2Fcommands%2FXXXXXXXXX%2F000000000000%2FXXXXXXXXXXXXXXXXXXXXXXXX&trigger_id=000000000000.0000000000.00000000000000000000000000000000",
      messageId: "",
      receiptHandle: "",
      attributes: {
        ApproximateReceiveCount: "",
        SentTimestamp: "",
        SenderId: "",
        ApproximateFirstReceiveTimestamp: ""
      },
      messageAttributes: {},
      md5OfBody: "",
      eventSource: "",
      eventSourceARN: "",
      awsRegion: ""
    },
    {
      body:
        "token=xxxxxxxxxxxxxxxxxxxxxxxx&team_id=XXXXXXXXX&team_domain=xxxxx&channel_id=XXXXXXXXX&channel_name=xxxxxxxxxxxx&user_id=XXXXXXXXX&user_name=xxxxxxxxxxxx&command=%2Fbar&text=&response_url=https%3A%2F%2Fhooks.slack.com%2Fcommands%2FXXXXXXXXX%2F000000000000%2FXXXXXXXXXXXXXXXXXXXXXXXX&trigger_id=000000000000.0000000000.00000000000000000000000000000000",
      messageId: "",
      receiptHandle: "",
      attributes: {
        ApproximateReceiveCount: "",
        SentTimestamp: "",
        SenderId: "",
        ApproximateFirstReceiveTimestamp: ""
      },
      messageAttributes: {},
      md5OfBody: "",
      eventSource: "",
      eventSourceARN: "",
      awsRegion: ""
    },
    {
      body:
        "token=xxxxxxxxxxxxxxxxxxxxxxxx&team_id=XXXXXXXXX&team_domain=xxxxx&channel_id=XXXXXXXXX&channel_name=xxxxxxxxxxxx&user_id=XXXXXXXXX&user_name=xxxxxxxxxxxx&command=%2Fbaz&text=&response_url=https%3A%2F%2Fhooks.slack.com%2Fcommands%2FXXXXXXXXX%2F000000000000%2FXXXXXXXXXXXXXXXXXXXXXXXX&trigger_id=000000000000.0000000000.00000000000000000000000000000000",
      messageId: "",
      receiptHandle: "",
      attributes: {
        ApproximateReceiveCount: "",
        SentTimestamp: "",
        SenderId: "",
        ApproximateFirstReceiveTimestamp: ""
      },
      messageAttributes: {},
      md5OfBody: "",
      eventSource: "",
      eventSourceARN: "",
      awsRegion: ""
    }
  ]
};

handler(event).then((responses: Response[]) => responses.map(response => assert.strictEqual(response.status, 500)));
