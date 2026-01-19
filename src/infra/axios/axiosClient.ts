import axios from "axios";
import { setupInterceptors } from "./interceptor";

const baseURL = process.env.NEXT_PUBLIC_API_BASE_URL || "http://localhost:3001/api";

export const axiosClient = axios.create({
  baseURL,
  headers: {
    "Content-Type": "application/json",
  },
  timeout: 30000,
});

setupInterceptors(axiosClient);
