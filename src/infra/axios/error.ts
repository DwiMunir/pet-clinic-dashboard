import { AxiosError } from "axios";

export interface ErrorResponse {
  message: string;
  statusCode?: number;
  errors?: Record<string, string[]>;
}

export const handleApiError = (error: AxiosError<ErrorResponse>) => {
  if (error.response) {
    // Server responded with error
    const { status, data } = error.response;
    
    switch (status) {
      case 401:
        console.error("Unauthorized - Please login again");
        // Redirect to login or refresh token
        if (typeof window !== "undefined") {
          localStorage.removeItem("authToken");
          window.location.href = "/auth/login";
        }
        break;
      case 403:
        console.error("Forbidden - You don't have permission");
        break;
      case 404:
        console.error("Not Found - Resource not found");
        break;
      case 500:
        console.error("Server Error - Please try again later");
        break;
      default:
        console.error(data?.message || "An error occurred");
    }
  } else if (error.request) {
    // Request made but no response
    console.error("Network Error - Please check your connection");
  } else {
    // Something else happened
    console.error("Error:", error.message);
  }
};
