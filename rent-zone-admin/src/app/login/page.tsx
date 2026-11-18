"use client";

import { useState } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { AlertCircle, ArrowLeft, Eye, EyeOff, Lock, Mail, ShirtIcon } from "lucide-react";
import { cn } from "@/lib/utils";
import { auth } from "@/lib/auth";

export default function LoginPage() {
  const router = useRouter();
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [showPassword, setShowPassword] = useState(false);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");

  const handleLogin = async (event: React.FormEvent<HTMLFormElement>) => {
    event.preventDefault();
    setLoading(true);
    setError("");

    try {
      await auth.login(email, password);
      await auth.getMe();
      router.replace("/dashboard");
    } catch (err: unknown) {
      auth.logout();
      const message = err instanceof Error ? err.message : "Unable to sign in. Please try again.";
      setError(
        message.toLowerCase().includes("admin access")
          ? "This account does not have administrator access."
          : message
      );
    } finally {
      setLoading(false);
    }
  };

  return (
    <main className="relative flex min-h-screen items-center justify-center overflow-hidden bg-[#fbfaff] p-5 text-[#211936] sm:p-8">
      <div className="pointer-events-none absolute -left-44 top-[-100px] h-[450px] w-[450px] rounded-full bg-violet-200/50 blur-[100px]" />
      <div className="pointer-events-none absolute -bottom-48 -right-36 h-[500px] w-[500px] rounded-full bg-fuchsia-100/70 blur-[110px]" />

      <Link
        href="/"
        className="absolute left-5 top-6 inline-flex items-center gap-2 text-sm font-medium text-[#797185] transition hover:text-[#7043cf] sm:left-8 sm:top-8"
      >
        <ArrowLeft size={16} /> Back to Rent Zone
      </Link>

      <div className="relative w-full max-w-[460px] py-16">
        <div className="rounded-[28px] border border-[#eee8f7] bg-white p-7 shadow-[0_28px_90px_-42px_rgba(75,48,119,0.32)] sm:p-10">
          <div className="mb-8">
            <div className="mb-7 flex h-12 w-12 items-center justify-center rounded-[17px] bg-gradient-to-br from-[#8b5cf6] to-[#6d36d8] text-white shadow-lg shadow-violet-200/80">
              <ShirtIcon size={23} strokeWidth={2.2} />
            </div>
            <p className="text-xs font-semibold uppercase tracking-[0.17em] text-[#8054dc]">
              Your Rent Zone workspace
            </p>
            <h1 className="mt-2 text-[34px] font-semibold tracking-[-0.06em] text-[#211936]">
              Welcome back
            </h1>
            <p className="mt-2 text-sm leading-6 text-[#81788f]">
              Sign in to keep your marketplace moving.
            </p>
          </div>

          <form onSubmit={handleLogin} className="space-y-5">
            {error && (
              <div
                role="alert"
                className="flex items-start gap-2.5 rounded-xl border border-red-100 bg-red-50 p-3.5 text-sm text-red-700"
              >
                <AlertCircle size={17} className="mt-0.5 shrink-0" />
                <span>{error}</span>
              </div>
            )}

            <div className="space-y-2">
              <label htmlFor="email" className="block text-sm font-semibold text-[#40384e]">
                Email address
              </label>
              <div className="relative">
                <Mail size={17} className="absolute left-3.5 top-1/2 -translate-y-1/2 text-[#a098ac]" />
                <input
                  id="email"
                  type="email"
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  placeholder="you@example.com"
                  autoComplete="email"
                  autoCapitalize="none"
                  spellCheck={false}
                  required
                  className={cn(
                    "w-full rounded-xl border border-[#eae5f0] bg-[#fdfcff] py-3 pl-11 pr-4 text-sm text-[#332a43] outline-none transition placeholder:text-[#b2abba] focus:border-[#a98be7] focus:bg-white focus:ring-4 focus:ring-[#8b5cf6]/10",
                    error && "border-red-300 focus:border-red-400 focus:ring-red-100"
                  )}
                />
              </div>
            </div>

            <div className="space-y-2">
              <label htmlFor="password" className="block text-sm font-semibold text-[#40384e]">
                Password
              </label>
              <div className="relative">
                <Lock size={17} className="absolute left-3.5 top-1/2 -translate-y-1/2 text-[#a098ac]" />
                <input
                  id="password"
                  type={showPassword ? "text" : "password"}
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  placeholder="Enter your password"
                  autoComplete="current-password"
                  required
                  className={cn(
                    "w-full rounded-xl border border-[#eae5f0] bg-[#fdfcff] py-3 pl-11 pr-12 text-sm text-[#332a43] outline-none transition placeholder:text-[#b2abba] focus:border-[#a98be7] focus:bg-white focus:ring-4 focus:ring-[#8b5cf6]/10",
                    error && "border-red-300 focus:border-red-400 focus:ring-red-100"
                  )}
                />
                <button
                  type="button"
                  onClick={() => setShowPassword(!showPassword)}
                  aria-label={showPassword ? "Hide password" : "Show password"}
                  aria-pressed={showPassword}
                  className="absolute right-3.5 top-1/2 -translate-y-1/2 text-[#a098ac] transition hover:text-[#6f43c8]"
                >
                  {showPassword ? <EyeOff size={16} /> : <Eye size={16} />}
                </button>
              </div>
            </div>

            <button
              type="submit"
              disabled={loading}
              className="mt-2 inline-flex w-full items-center justify-center gap-2 rounded-xl bg-gradient-to-r from-[#8250e8] to-[#713bd7] py-3.5 text-sm font-semibold text-white shadow-lg shadow-violet-200/70 transition hover:-translate-y-0.5 hover:shadow-xl hover:shadow-violet-200/80 disabled:cursor-not-allowed disabled:opacity-60"
            >
              {loading && (
                <span className="h-4 w-4 animate-spin rounded-full border-2 border-white/40 border-t-white" />
              )}
              {loading ? "Signing in..." : "Sign in to your workspace"}
            </button>
          </form>

          <div className="mt-6 flex items-start gap-2.5 rounded-xl bg-[#f8f5fd] p-3.5">
            <Lock size={14} className="mt-0.5 shrink-0 text-[#7950d8]" />
            <p className="text-xs leading-5 text-[#777084]">
              This workspace is for authorized Rent Zone administrators. Your account is verified securely when you sign in.
            </p>
          </div>
        </div>

        <p className="mt-6 text-center text-xs text-[#9991a4]">
          © {new Date().getFullYear()} Rent Zone
        </p>
      </div>
    </main>
  );
}
