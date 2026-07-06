"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import {
  LayoutDashboard, Users, Package, Grid3X3, CalendarCheck, Flag,
  Star, MessageSquare, Bell, Wand2, BarChart3, Shield, Settings,
  ShirtIcon, ChevronLeft, ChevronRight,
} from "lucide-react";
import { cn } from "@/lib/utils";
import { useState } from "react";

const navItems = [
  { href: "/dashboard",    label: "Dashboard",       icon: LayoutDashboard },
  { href: "/users",        label: "Users",           icon: Users },
  { href: "/products",     label: "Products",        icon: Package },
  { href: "/categories",   label: "Categories",      icon: Grid3X3 },
  { href: "/rentals",      label: "Rentals",         icon: CalendarCheck },
  { href: "/reports",      label: "Reports",         icon: Flag },
  { href: "/reviews",      label: "Reviews",         icon: Star },
  { href: "/chats",        label: "Chats",           icon: MessageSquare },
  { href: "/notifications",label: "Notifications",   icon: Bell },
  { href: "/try-ons",      label: "Virtual Try-Ons", icon: Wand2 },
  { href: "/yce-keys",     label: "YCE API Keys",    icon: Settings },
  { href: "/analytics",    label: "Analytics",       icon: BarChart3 },
  { href: "/audit-logs",   label: "Audit Logs",      icon: Shield },
  { href: "/settings",     label: "Settings",        icon: Settings },
];

const badges: Record<string, number> = {
  "/reports": 12,
  "/chats": 34,
};

export default function Sidebar() {
  const pathname = usePathname();
  const [collapsed, setCollapsed] = useState(false);

  return (
    <aside
      className={cn(
        "flex flex-col bg-white border-r border-gray-100 shadow-sidebar transition-all duration-300 ease-in-out h-screen sticky top-0 z-40",
        collapsed ? "w-16" : "w-64"
      )}
    >
      {/* Logo */}
      <div className={cn(
        "flex items-center gap-3 px-4 py-5 border-b border-gray-100",
        collapsed && "justify-center px-3"
      )}>
        <div className="flex-shrink-0 w-9 h-9 bg-gradient-to-br from-purple-600 to-violet-600 rounded-xl flex items-center justify-center shadow-md">
          <ShirtIcon className="w-5 h-5 text-white" />
        </div>
        {!collapsed && (
          <div>
            <p className="text-sm font-bold text-gray-900 leading-none">Rent Zone</p>
            <p className="text-xs text-purple-600 font-medium mt-0.5">Admin Console</p>
          </div>
        )}
      </div>

      {/* Nav */}
      <nav className="flex-1 px-3 py-4 space-y-0.5 overflow-y-auto">
        {navItems.map(({ href, label, icon: Icon }) => {
          const isActive = pathname === href || pathname.startsWith(href + "/");
          const badge = badges[href];
          return (
            <Link
              key={href}
              href={href}
              className={cn(
                "nav-item group relative",
                isActive && "active",
                collapsed && "justify-center px-2"
              )}
              title={collapsed ? label : undefined}
            >
              <Icon
                className={cn(
                  "w-4.5 h-4.5 flex-shrink-0 transition-colors",
                  isActive ? "text-purple-600" : "text-gray-400 group-hover:text-purple-500"
                )}
                size={18}
              />
              {!collapsed && (
                <span className="flex-1">{label}</span>
              )}
              {!collapsed && badge && (
                <span className="ml-auto flex items-center justify-center w-5 h-5 bg-red-500 text-white text-[10px] font-bold rounded-full">
                  {badge > 9 ? "9+" : badge}
                </span>
              )}
              {collapsed && badge && (
                <span className="absolute top-1 right-1 w-2 h-2 bg-red-500 rounded-full" />
              )}
            </Link>
          );
        })}
      </nav>

      {/* Collapse toggle */}
      <div className="px-3 py-4 border-t border-gray-100">
        <button
          onClick={() => setCollapsed(!collapsed)}
          className={cn(
            "w-full flex items-center gap-2 px-3 py-2 rounded-lg text-sm text-gray-400 hover:text-purple-600 hover:bg-purple-50 transition-all",
            collapsed && "justify-center"
          )}
        >
          {collapsed ? <ChevronRight size={16} /> : (
            <>
              <ChevronLeft size={16} />
              <span className="text-xs">Collapse</span>
            </>
          )}
        </button>
      </div>
    </aside>
  );
}
