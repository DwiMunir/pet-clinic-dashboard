import { AxiosInstance, AxiosError, InternalAxiosRequestConfig } from "axios";
import { ErrorResponse, handleApiError } from "./error";

export const setupInterceptors = (axiosInstance: AxiosInstance) => {
  // Request interceptor
  axiosInstance.interceptors.request.use(
    (config: InternalAxiosRequestConfig) => {
      // Add auth token if available
      if (typeof window !== "undefined") {
        const token = localStorage.getItem("authToken");
        if (token && config.headers) {
          config.headers.Authorization = `Bearer ${token}`;
        }
      }
      return config;
    },
    (error: AxiosError) => {
      return Promise.reject(error);
    }
  );

  // Response interceptor
  axiosInstance.interceptors.response.use(
    (response) => response,
    (error: AxiosError<ErrorResponse>) => {
      handleApiError(error);
      return Promise.reject(error);
    }
  );
};
