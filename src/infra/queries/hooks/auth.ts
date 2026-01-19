import { useQuery, useMutation } from "@tanstack/react-query";
import { QueryKey } from "../queryKey";
import * as authService from "@infra/services/api/authService";
import { LoginRequest, RegisterRequest } from "@types-app/auth";

export const useQueryGetMe = () =>
  useQuery({
    queryKey: [QueryKey.GET_ME],
    queryFn: authService.getMe,
  });

export const useMutationLogin = () =>
  useMutation({
    mutationFn: (data: LoginRequest) => authService.login(data),
  });

export const useMutationRegister = () =>
  useMutation({
    mutationFn: (data: RegisterRequest) => authService.register(data),
  });
