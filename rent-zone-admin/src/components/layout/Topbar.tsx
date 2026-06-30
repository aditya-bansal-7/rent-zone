"use client";

import { Bell, Search, ChevronDown, LogOut, User, Settings } from "lucide-react";
import { useRouter, usePathname } from "next/navigation";
import { useState, useEffect } from "react";
import { cn, getInitials } from "@/lib/utils";
import { auth } from "@/lib/auth";

const pageTitles: Record<string, string> = {
  "/dashboard":     "Dashboard",
  "/users":         "User Management",
  "/products":      "Product Listings",
  "/categories":    "Category Management",
  "/rentals":       "Rental Management",
  "/reports":       "Reports & Moderation",
  "/reviews":       "Review Moderation",
  "/chats":         "Chat Monitoring",
  "/notifications": "Notifications",
  "/try-ons":       "Virtual Try-Ons",
  "/analytics":     "Analytics & Reports",
  "/audit-logs":    "Audit Logs",
  "/settings":      "System Settings",
};

export default function Topbar() {
  const router = useRouter();
  const pathname = usePathname();
  const [showDropdown, setShowDropdown] = useState(false);
  const [searchValue, setSearchValue] = useState("");
  const [adminName, setAdminName] = useState("Admin");
  const [adminEmail, setAdminEmail] = useState("");

  const title = Object.entries(pageTitles).find(([k]) =>
    pathname === k || pathname.startsWith(k + "/")
  )?.[1] ?? "Admin";

  useEffect(() => {
    auth.getMe().then((me) => {
      setAdminName(me.name || "Admin");
      setAdminEmail(me.email || "");
    }).catch(() => {});
  }, []);

  const handleLogout = () => {
    auth.logout();
    router.push("/login");
  };

  return (
    <header className="sticky top-0 z-30 bg-white border-b border-gray-100 px-6 h-16 flex items-center justify-between gap-4">
      {/* Page title */}
      <h1 className="text-base font-semibold text-gray-900 hidden md:block">{title}</h1>

      {/* Search */}
      <div className="flex-1 max-w-md relative">
        <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400 w-4 h-4" />
        <input
          type="text"
          placeholder="Search users, products, rentals..."
          value={searchValue}
          onChange={(e) => setSearchValue(e.target.value)}
          className="w-full pl-9 pr-4 py-2 text-sm bg-gray-50 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-purple-500/30 focus:border-purple-400 focus:bg-white transition-all"
        />
      </div>

      {/* Right side */}
      <div className="flex items-center gap-2">
        {/* Notification bell */}
        <button className="relative w-9 h-9 rounded-lg hover:bg-purple-50 flex items-center justify-center text-gray-500 hover:text-purple-600 transition-colors">
          <Bell size={18} />
          <span className="absolute top-1.5 right-1.5 w-2 h-2 bg-red-500 rounded-full" />
        </button>

        {/* Profile dropdown */}
        <div className="relative">
          <button
            onClick={() => setShowDropdown(!showDropdown)}
            className="flex items-center gap-2.5 px-3 py-1.5 rounded-lg hover:bg-gray-50 transition-colors"
          >
            <div className="w-7 h-7 bg-gradient-to-br from-purple-500 to-violet-600 rounded-full flex items-center justify-center">
              <span className="text-white text-xs font-bold">{getInitials(adminName)}</span>
            </div>
            <div className="hidden md:block text-left">
              <p className="text-xs font-semibold text-gray-900 leading-none">{adminName}</p>
              <p className="text-[10px] text-gray-400 mt-0.5">Super Admin</p>
            </div>
            <ChevronDown size={14} className="text-gray-400" />
          </button>

          {showDropdown && (
            <div className={cn(
              "absolute right-0 top-full mt-2 w-52 bg-white rounded-xl border border-gray-100 shadow-modal py-1.5 z-50 animate-slide-in"
            )}>
              <div className="px-3 py-2 border-b border-gray-50">
                <p className="text-sm font-semibold text-gray-900">{adminName}</p>
                <p className="text-xs text-gray-400">{adminEmail}</p>
              </div>
              <button
                onClick={() => { router.push("/settings"); setShowDropdown(false); }}
                className="w-full flex items-center gap-3 px-3 py-2 text-sm text-gray-600 hover:bg-gray-50 transition-colors"
              >
                <Settings size={15} /> Settings
              </button>
              <button
                onClick={() => { setShowDropdown(false); }}
                className="w-full flex items-center gap-3 px-3 py-2 text-sm text-gray-600 hover:bg-gray-50 transition-colors"
              >
                <User size={15} /> Profile
              </button>
              <div className="border-t border-gray-100 mt-1 pt-1">
                <button
                  onClick={handleLogout}
                  className="w-full flex items-center gap-3 px-3 py-2 text-sm text-red-500 hover:bg-red-50 transition-colors"
                >
                  <LogOut size={15} /> Sign Out
                </button>
              </div>
            </div>
          )}
        </div>
      </div>
    </header>
  );
}
