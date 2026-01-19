"use client";

import { useState } from "react";
import { MyTextInput } from "@/components/atoms/my-text-input";
import { MyButton } from "@/components/atoms/my-button";
import { MyCheckbox } from "@/components/atoms/my-checkbox";
import { useRouter, usePathname } from "@/i18n/navigation";
import { useParams } from "next/navigation";
import { useTranslations } from "next-intl";
import Link from "next/link";

const SignInPage = () => {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [rememberMe, setRememberMe] = useState(false);
  const [isLoading, setIsLoading] = useState(false);
  const router = useRouter();
  const pathname = usePathname();
  const params = useParams();
  const currentLocale = (params?.locale as string) || "en";
  const t = useTranslations("auth");

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setIsLoading(true);

    // TODO: Implement authentication logic
    await new Promise((resolve) => setTimeout(resolve, 1000));

    setIsLoading(false);
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-linear-to-br from-blue-50 via-indigo-50 to-purple-50 p-4">
      <div className="w-full max-w-6xl bg-white rounded-2xl shadow-2xl overflow-hidden">
        <div className="flex flex-col lg:flex-row">
          {/* Left Side - Illustration */}
          <div className="lg:w-1/2 bg-linear-to-br from-blue-100 via-purple-100 to-pink-100 p-8 lg:p-12 flex items-center justify-center relative overflow-hidden">
            <div className="relative z-10 w-full max-w-md">
              {/* Decorative shapes */}
              <div className="absolute top-8 left-8 w-16 h-16 bg-purple-300 opacity-30 rounded-lg transform rotate-12" />
              <div className="absolute bottom-12 right-8 w-20 h-20 bg-blue-300 opacity-30 rounded-lg transform -rotate-12" />
              <div className="absolute top-32 right-12 w-12 h-12 bg-pink-300 opacity-30 rounded-lg transform rotate-45" />

              {/* Main illustration elements */}
              <div className="relative">
                {/* Card with checkmark */}
                <div className="bg-white bg-opacity-80 backdrop-blur-sm rounded-xl p-6 shadow-xl transform -rotate-3 mb-8">
                  <div className="absolute -top-4 -left-4 w-12 h-12 bg-cyan-400 rounded-full flex items-center justify-center shadow-lg">
                    <svg
                      className="w-7 h-7 text-white"
                      fill="none"
                      stroke="currentColor"
                      viewBox="0 0 24 24"
                    >
                      <path
                        strokeLinecap="round"
                        strokeLinejoin="round"
                        strokeWidth={3}
                        d="M5 13l4 4L19 7"
                      />
                    </svg>
                  </div>
                  <div className="flex items-center gap-4 mb-4">
                    <div className="w-12 h-12 bg-linear-to-br from-purple-400 to-blue-400 rounded-full flex items-center justify-center">
                      <svg
                        className="w-7 h-7 text-white"
                        fill="none"
                        stroke="currentColor"
                        viewBox="0 0 24 24"
                      >
                        <path
                          strokeLinecap="round"
                          strokeLinejoin="round"
                          strokeWidth={2}
                          d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"
                        />
                      </svg>
                    </div>
                    <div className="flex-1">
                      <div className="h-2 bg-gray-200 rounded w-3/4 mb-2" />
                      <div className="h-2 bg-gray-200 rounded w-1/2" />
                    </div>
                  </div>
                  <div className="space-y-2">
                    <div className="h-2 bg-gray-100 rounded" />
                    <div className="h-2 bg-gray-100 rounded w-5/6" />
                  </div>
                </div>

                {/* Lock icon */}
                <div className="absolute bottom-0 right-0 transform translate-x-8 translate-y-8">
                  <div className="w-24 h-28 bg-linear-to-br from-cyan-400 to-blue-500 rounded-t-3xl shadow-xl relative">
                    <div className="absolute top-6 left-1/2 transform -translate-x-1/2 w-10 h-10 border-4 border-white rounded-full" />
                    <div className="absolute top-12 left-1/2 transform -translate-x-1/2 w-6 h-8 bg-white rounded-full" />
                    <div className="absolute bottom-6 left-1/2 transform -translate-x-1/2 w-4 h-4 bg-white rounded-full" />
                  </div>
                </div>

                {/* Document */}
                <div className="absolute -bottom-4 left-8 w-20 h-24 bg-linear-to-br from-pink-300 to-red-300 rounded-lg shadow-lg transform rotate-12 p-3">
                  <div className="space-y-2">
                    <div className="h-1.5 bg-white rounded" />
                    <div className="h-1.5 bg-white rounded w-4/5" />
                    <div className="h-1.5 bg-white rounded w-3/5" />
                  </div>
                </div>
              </div>
            </div>
          </div>

          {/* Right Side - Form */}
          <div className="lg:w-1/2 p-8 lg:p-12 flex flex-col justify-center">
            <div className="w-full max-w-md mx-auto">
              {/* Logo/Brand */}
              <div className="text-center mb-8">
                <h1 className="text-2xl font-bold text-gray-900 tracking-wide">
                  {t("brandName")}
                </h1>
                <p className="text-xs text-gray-500 tracking-widest mt-1">
                  {t("brandSubtitle")}
                </p>
              </div>

              {/* Sign In Title */}
              <div className="mb-8">
                <h2 className="text-3xl font-bold text-gray-900 border-b-4 border-gray-900 inline-block pb-1">
                  {t("signIn")}
                </h2>
              </div>

              {/* Form */}
              <form onSubmit={handleSubmit} className="space-y-6">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    {t("emailAddress")}
                  </label>
                  <MyTextInput
                    type="email"
                    value={email}
                    onChange={(e) => setEmail(e.target.value)}
                    placeholder={t("enterEmail")}
                    required
                    className="text-sm"
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    {t("password")}
                  </label>
                  <MyTextInput
                    type="password"
                    value={password}
                    onChange={(e) => setPassword(e.target.value)}
                    placeholder={t("enterPassword")}
                    required
                    className="text-sm"
                  />
                </div>

                <div className="flex items-center justify-between">
                  <MyCheckbox
                    checked={rememberMe}
                    onChange={(e) => setRememberMe(e.target.checked)}
                    label={t("rememberMe")}
                  />
                  <Link
                    href="/forgot-password"
                    className="text-sm text-cyan-500 hover:text-cyan-600 font-medium transition-colors"
                  >
                    {t("forgotPassword")}
                  </Link>
                </div>

                <MyButton
                  type="submit"
                  variant="primary"
                  size="lg"
                  isLoading={isLoading}
                  className="w-full bg-cyan-500 hover:bg-cyan-600 focus:ring-cyan-500 text-base font-semibold"
                >
                  {t("signIn")}
                </MyButton>
              </form>

              {/* Sign Up Link */}
              <p className="text-center text-sm text-gray-600 mt-6">
                {t("dontHaveAccount")}{" "}
                <Link
                  href="/auth/signup"
                  className="text-cyan-500 hover:text-cyan-600 font-semibold transition-colors"
                >
                  {t("createAccount")}
                </Link>
              </p>

              {/* Language Switcher */}
              <div className="mt-8 flex items-center justify-center gap-2">
                <span className="text-sm text-gray-500">{t("language")}:</span>
                <div className="flex gap-2">
                  <button
                    onClick={() => {
                      router.push(pathname, { locale: "en" });
                    }}
                    className={`px-4 py-2 rounded-lg text-sm font-medium transition-all ${
                      currentLocale === "en"
                        ? "bg-cyan-500 text-white shadow-md"
                        : "bg-gray-100 text-gray-700 hover:bg-gray-200"
                    }`}
                  >
                    🇺🇸 {t("english")}
                  </button>
                  <button
                    onClick={() => {
                      router.push(pathname, { locale: "id" });
                    }}
                    className={`px-4 py-2 rounded-lg text-sm font-medium transition-all ${
                      currentLocale === "id"
                        ? "bg-cyan-500 text-white shadow-md"
                        : "bg-gray-100 text-gray-700 hover:bg-gray-200"
                    }`}
                  >
                    🇮🇩 {t("indonesian")}
                  </button>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default SignInPage;
