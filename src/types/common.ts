export interface BaseResponse<T = unknown> {
  data: T;
  message: string;
  success: boolean;
}

export interface ErrorDetail {
  field: string;
  message: string;
}
