import { getTranslations } from "next-intl/server";

export default async function NotFound() {
  const t = await getTranslations("common");

  return (
    <div className="flex min-h-screen flex-col items-center justify-center">
      <h1 className="text-4xl font-bold">{t("error")}</h1>
      <p className="mt-4 text-gray-600">Page not found</p>
    </div>
  );
}
