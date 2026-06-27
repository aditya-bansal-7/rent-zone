import { type ClassValue, clsx } from "clsx";
import { twMerge } from "tailwind-merge";
import { format, formatDistanceToNow, parseISO } from "date-fns";

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

export function formatDate(date: string | Date): string {
  return format(typeof date === "string" ? parseISO(date) : date, "MMM d, yyyy");
}

export function formatDateTime(date: string | Date): string {
  return format(typeof date === "string" ? parseISO(date) : date, "MMM d, yyyy 'at' h:mm a");
}

export function formatRelativeTime(date: string | Date): string {
  return formatDistanceToNow(typeof date === "string" ? parseISO(date) : date, { addSuffix: true });
}

export function formatCurrency(amount: number, currency = "INR"): string {
  return new Intl.NumberFormat("en-IN", {
    style: "currency",
    currency,
    maximumFractionDigits: 0,
  }).format(amount);
}

export function formatNumber(num: number): string {
  if (num >= 1_000_000) return `${(num / 1_000_000).toFixed(1)}M`;
  if (num >= 1_000) return `${(num / 1_000).toFixed(1)}K`;
  return num.toString();
}

export function getInitials(name: string): string {
  return name
    .split(" ")
    .slice(0, 2)
    .map((n) => n[0])
    .join("")
    .toUpperCase();
}

export function truncate(str: string, length: number): string {
  return str.length > length ? `${str.slice(0, length)}...` : str;
}

export function slugify(str: string): string {
  return str.toLowerCase().replace(/\s+/g, "-").replace(/[^\w-]/g, "");
}

// Status colors
export const rentalStatusColors: Record<string, string> = {
  requested: "badge-yellow",
  approved: "badge-blue",
  active: "badge-green",
  returned: "badge-gray",
  cancelled: "badge-red",
};

export const reportStatusColors: Record<string, string> = {
  pending: "badge-yellow",
  valid: "badge-red",
  invalid: "badge-gray",
  escalated: "badge-purple",
};

export const userStatusColors: Record<string, string> = {
  active: "badge-green",
  suspended: "badge-yellow",
  banned: "badge-red",
};

export const productStatusColors: Record<string, string> = {
  active: "badge-green",
  hidden: "badge-yellow",
  archived: "badge-gray",
  featured: "badge-purple",
};

export const tryOnStatusColors: Record<string, string> = {
  pending: "badge-yellow",
  completed: "badge-green",
  failed: "badge-red",
  flagged: "badge-purple",
};

export function debounce<T extends (...args: unknown[]) => void>(fn: T, ms: number): T {
  let timeout: ReturnType<typeof setTimeout>;
  return ((...args: unknown[]) => {
    clearTimeout(timeout);
    timeout = setTimeout(() => fn(...args), ms);
  }) as T;
}
