"use client";

import { useState } from "react";
import { MyTextInput } from "@/components/atoms/my-text-input";
import { MyButton } from "@/components/atoms/my-button";
import { MyCheckbox } from "@/components/atoms/my-checkbox";
import { useRouter, usePathname } from "@/i18n/navigation";
import { useParams } from "next/navigation";
import { useTranslations } from "next-intl";
import Link from "next/link";

const SignUpPage = () => {
  const [fullName, setFullName] = useState("");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [confirmPassword, setConfirmPassword] = useState("");
  const [agreeToTerms, setAgreeToTerms] = useState(false);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState("");
  const router = useRouter();
  const pathname = usePathname();
  const params = useParams();
  const currentLocale = (params?.locale as string) || "en";
  const t = useTranslations("auth");

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError("");

    // Validate passwords match
    if (password !== confirmPassword) {
      setError(t("passwordMismatch"));
      return;
    }

    if (!agreeToTerms) {
      return;
    }

    setIsLoading(true);

    // TODO: Implement registration logic
    await new Promise((resolve) => setTimeout(resolve, 1000));

    setIsLoading(false);
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-linear-to-br from-blue-50 via-indigo-50 to-purple-50 p-4">
      <div className="w-full max-w-6xl bg-white rounded-2xl shadow-2xl overflow-hidden">
        <div className="flex flex-col lg:flex-row">
          {/* Left Side - Illustration */}
          <div className="lg:w-1/2 bg-linear-to-br from-cyan-100 via-blue-100 to-indigo-100 p-8 lg:p-12 flex items-center justify-center relative overflow-hidden">
            <div className="relative z-10 w-full max-w-md">
              {/* Decorative shapes */}
              <div className="absolute top-8 right-8 w-16 h-16 bg-blue-300 opacity-30 rounded-lg transform -rotate-12" />
              <div className="absolute bottom-12 left-8 w-20 h-20 bg-cyan-300 opacity-30 rounded-lg transform rotate-12" />
              <div className="absolute top-32 left-12 w-12 h-12 bg-indigo-300 opacity-30 rounded-lg transform -rotate-45" />

              {/* Main illustration elements */}
              <div className="relative">
                {/* Card with user icon */}
                <div className="bg-white bg-opacity-80 backdrop-blur-sm rounded-xl p-6 shadow-xl transform rotate-3 mb-8">
                  <div className="absolute -top-4 -right-4 w-12 h-12 bg-cyan-400 rounded-full flex items-center justify-center shadow-lg">
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
                        d="M12 4v16m8-8H4"
                      />
                    </svg>
                  </div>
                  <div className="flex flex-col items-center gap-4 mb-4">
                    <div className="w-20 h-20 bg-linear-to-br from-cyan-400 to-blue-400 rounded-full flex items-center justify-center ring-4 ring-white">
                      <svg
                        className="w-10 h-10 text-white"
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
                    <div className="w-full">
                      <div className="h-2 bg-gray-200 rounded w-3/4 mx-auto mb-2" />
                      <div className="h-2 bg-gray-200 rounded w-1/2 mx-auto" />
                    </div>
                  </div>
                  <div className="space-y-2">
                    <div className="h-2 bg-gray-100 rounded" />
                    <div className="h-2 bg-gray-100 rounded w-5/6 mx-auto" />
                  </div>
                </div>

                {/* Document with pen */}
                <div className="absolute bottom-0 left-0 transform -translate-x-8 translate-y-8">
                  <div className="w-24 h-28 bg-linear-to-br from-blue-400 to-cyan-500 rounded-lg shadow-xl relative p-3">
                    <div className="space-y-1.5">
                      <div className="h-1.5 bg-white rounded" />
                      <div className="h-1.5 bg-white rounded w-4/5" />
                      <div className="h-1.5 bg-white rounded w-3/5" />
                    </div>
                    {/* Pen icon */}
                    <div className="absolute -bottom-2 -right-2 w-8 h-8 bg-yellow-400 rounded-full flex items-center justify-center shadow-lg">
                      <svg
                        className="w-4 h-4 text-white"
                        fill="currentColor"
                        viewBox="0 0 20 20"
                      >
                        <path d="M13.586 3.586a2 2 0 112.828 2.828l-.793.793-2.828-2.828.793-.793zM11.379 5.793L3 14.172V17h2.828l8.38-8.379-2.83-2.828z" />
                      </svg>
                    </div>
                  </div>
                </div>

                {/* Envelope */}
                <div className="absolute -bottom-4 right-8 w-20 h-16 bg-linear-to-br from-cyan-300 to-blue-400 rounded-lg shadow-lg transform -rotate-12 p-3 flex items-center justify-center">
                  <svg
                    className="w-10 h-10 text-white"
                    fill="none"
                    stroke="currentColor"
                    viewBox="0 0 24 24"
                  >
                    <path
                      strokeLinecap="round"
                      strokeLinejoin="round"
                      strokeWidth={2}
                      d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"
                    />
                  </svg>
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

              {/* Sign Up Title */}
              <div className="mb-8">
                <h2 className="text-3xl font-bold text-gray-900 border-b-4 border-gray-900 inline-block pb-1">
                  {t("signUp")}
                </h2>
              </div>

              {/* Form */}
              <form onSubmit={handleSubmit} className="space-y-5">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    {t("fullName")}
                  </label>
                  <MyTextInput
                    type="text"
                    value={fullName}
                    onChange={(e) => setFullName(e.target.value)}
                    placeholder={t("enterFullName")}
                    required
                    className="text-sm"
                  />
                </div>

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

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    {t("confirmPassword")}
                  </label>
                  <MyTextInput
                    type="password"
                    value={confirmPassword}
                    onChange={(e) => setConfirmPassword(e.target.value)}
                    placeholder={t("enterConfirmPassword")}
                    required
                    error={error}
                    className="text-sm"
                  />
                </div>

                <div>
                  <MyCheckbox
                    checked={agreeToTerms}
                    onChange={(e) => setAgreeToTerms(e.target.checked)}
                    label={t("agreeToTerms")}
                    required
                  />
                </div>

                <MyButton
                  type="submit"
                  variant="primary"
                  size="lg"
                  isLoading={isLoading}
                  className="w-full bg-cyan-500 hover:bg-cyan-600 focus:ring-cyan-500 text-base font-semibold"
                >
                  {t("signUp")}
                </MyButton>
              </form>

              {/* Sign In Link */}
              <p className="text-center text-sm text-gray-600 mt-6">
                {t("alreadyHaveAccountSignIn")}{" "}
                <Link
                  href="/auth/signin"
                  className="text-cyan-500 hover:text-cyan-600 font-semibold transition-colors"
                >
                  {t("signIn")}
                </Link>
              </p>

              {/* Language Switcher */}
              <div className="mt-8 flex items-center justify-center gap-2">
                <span className="text-sm text-gray-500">{t("language")}:</span>
                <div className="flex gap-2">
                  <button
                    type="button"
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
                    type="button"
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

export default SignUpPage;
