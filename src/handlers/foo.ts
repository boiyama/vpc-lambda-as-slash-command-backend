import { AxiosRequestConfig } from "axios";
import { Payload } from "../slash-command";

export default (payload: Payload): AxiosRequestConfig => ({ url: payload.response_url, data: { text: "Fooed." } });
