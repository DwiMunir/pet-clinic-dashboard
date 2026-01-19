import { setRequestLocale } from "next-intl/server";
import { getTranslations } from "next-intl/server";

type Props = {
  params: Promise<{ locale: string }>;
};

export async function generateMetadata({ params }: Props) {
  const { locale } = await params;
  const t = await getTranslations({ locale, namespace: "common" });

  return {
    title: t("welcome"),
  };
}

export default async function HomePage({ params }: Props) {
  const { locale } = await params;

  // Enable static rendering
  setRequestLocale(locale);

  const t = await getTranslations("common");

  return (
    <div className="container mx-auto p-8">
      <h1 className="text-3xl font-bold">{t("welcome")}</h1>
      <p className="text-gray-600">Current locale: {locale}</p>
    </div>
  );
}
