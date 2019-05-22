import { SQSEvent } from "aws-lambda";
import axios, { AxiosPromise } from "axios";
import assoc from "lodash/fp/assoc";
import cond from "lodash/fp/cond";
import pick from "lodash/fp/pick";
import propEq from "lodash/fp/propEq";
import pipe from "lodash/fp/pipe";
import prop from "lodash/fp/prop";
import map from "lodash/fp/map";
import T from "lodash/fp/T";
import querystring from "querystring";
import console from "./console";
import fooHandler from "./handlers/foo";
import barHandler from "./handlers/bar";
import undefinedHandler from "./handlers/undefined";

export const handler = (event: SQSEvent) =>
  pipe(
    console.log,
    prop("Records"),
    map(
      pipe(
        prop("body"),
        querystring.parse,
        cond([[propEq("command", "/foo"), fooHandler], [propEq("command", "/bar"), barHandler], [T, undefinedHandler]])
      )
    ),
    values => Promise.all(values)
  )(event)
    .then(
      pipe(
        map(
          pipe(
            assoc("method", "POST"),
            console.log,
            axios,
            (promise: AxiosPromise) =>
              new Promise(resolve =>
                promise.then(resolve).catch(
                  pipe(
                    prop("response"),
                    resolve
                  )
                )
              )
          )
        ),
        values => Promise.all(values)
      )
    )
    .then(
      map(
        cond([
          [
            propEq("status", 200),
            pipe(
              pick(["status", "statusText", "data"]),
              console.log
            )
          ],
          [
            T,
            pipe(
              pick(["status", "statusText", "data", "config"]),
              console.error
            )
          ]
        ])
      )
    );
