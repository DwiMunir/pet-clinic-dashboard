import { axiosClient } from "@infra/axios";
import { LoginRequest, LoginResponse, RegisterRequest, User } from "@types-app/auth";

export const login = async (data: LoginRequest): Promise<LoginResponse> => {
  const response = await axiosClient.post<LoginResponse>("/auth/login", data);
  return response.data;
};

export const register = async (data: RegisterRequest): Promise<LoginResponse> => {
  const response = await axiosClient.post<LoginResponse>("/auth/register", data);
  return response.data;
};

export const getMe = async (): Promise<User> => {
  const response = await axiosClient.get<User>("/auth/me");
  return response.data;
};

export const logout = async (): Promise<void> => {
  await axiosClient.post("/auth/logout");
};
