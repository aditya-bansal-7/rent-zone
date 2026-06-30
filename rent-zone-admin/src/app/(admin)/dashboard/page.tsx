"use client";

import {
  Users, Package, CalendarCheck, Flag, MessageSquare,
  Star, Wand2, ArrowRight, IndianRupee,
} from "lucide-react";
import Link from "next/link";
import { useEffect, useState } from "react";
import {
  AreaChart, Area, BarChart, Bar,
  XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, PieChart, Pie, Cell,
} from "recharts";
import { adminService } from "@/services/admin";
import { formatCurrency, formatNumber, formatRelativeTime, rentalStatusColors } from "@/lib/utils";

const PIE_COLORS = ["#7c3aed", "#a855f7", "#c084fc", "#6366f1", "#818cf8", "#93c5fd"];

const quickActions = [
  { label: "Review Reports",    href: "/reports",   icon: Flag,      color: "text-red-500",    bg: "bg-red-50",    key: "pendingReports" },
  { label: "Verify Users",      href: "/users",     icon: Users,     color: "text-purple-600", bg: "bg-purple-50", key: "totalUsers" },
  { label: "Moderate Listings", href: "/products",  icon: Package,   color: "text-violet-600", bg: "bg-violet-50", key: "totalProducts" },
  { label: "Monitor Chats",     href: "/chats",     icon: MessageSquare, color: "text-blue-600", bg: "bg-blue-50", key: "totalChats" },
];

export default function DashboardPage() {
  const [stats, setStats] = useState<any>(null);
  const [rentals, setRentals] = useState<any[]>([]);
  const [logs, setLogs] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchData = async () => {
      try {
        const [statsRes, rentalsRes, logsRes] = await Promise.all([
          adminService.dashboard.getStats(),
          adminService.rentals.list({ limit: 5 }),
          adminService.auditLogs.list({ limit: 7 })
        ]);
        setStats(statsRes);
        setRentals(rentalsRes.rentals || []);
        setLogs(logsRes.logs || []);
      } catch (err) {
        console.error("Failed to load dashboard data", err);
      } finally {
        setLoading(false);
      }
    };
    fetchData();
  }, []);

  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-[500px]">
        <div className="w-8 h-8 border-4 border-purple-500 border-t-transparent rounded-full animate-spin"></div>
      </div>
    );
  }

  if (!stats) return <div>Failed to load dashboard.</div>;

  const kpiCards = [
    { label: "Total Users",       value: stats.totalUsers,      icon: Users,         color: "text-purple-600", bg: "bg-purple-50" },
    { label: "Active Listings",   value: stats.totalProducts,  icon: Package,       color: "text-violet-600", bg: "bg-violet-50" },
    { label: "Total Rentals",     value: stats.totalRentals,    icon: CalendarCheck, color: "text-indigo-600", bg: "bg-indigo-50" },
    { label: "Monthly Revenue",   value: stats.monthlyRevenue,  icon: IndianRupee,   color: "text-emerald-600",bg: "bg-emerald-50", isCurrency: true },
    { label: "Pending Reports",   value: stats.pendingReports,  icon: Flag,          color: "text-red-500",    bg: "bg-red-50" },
    { label: "Total Chats",       value: stats.totalChats,      icon: MessageSquare, color: "text-blue-600",   bg: "bg-blue-50" },
    { label: "Total Reviews",     value: stats.totalReviews,    icon: Star,          color: "text-amber-500",  bg: "bg-amber-50" },
    { label: "Try-On Requests",   value: stats.totalTryOns,   icon: Wand2,         color: "text-pink-600",   bg: "bg-pink-50" },
  ];

  return (
    <div className="space-y-6 max-w-[1400px]">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h2 className="text-2xl font-bold text-gray-900">Platform Overview</h2>
          <p className="text-sm text-gray-500 mt-0.5">Welcome back! Here's what's happening on Rent Zone.</p>
        </div>
        <div className="flex items-center gap-2 text-xs text-gray-400 bg-gray-50 px-3 py-1.5 rounded-lg border border-gray-100">
          <div className="w-2 h-2 bg-emerald-400 rounded-full animate-pulse" />
          Live — updated just now
        </div>
      </div>

      {/* KPI Cards */}
      <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
        {kpiCards.map((kpi) => {
          const Icon = kpi.icon;
          return (
            <div key={kpi.label} className="admin-card p-5 hover:shadow-card-hover transition-shadow">
              <div className="flex items-start justify-between mb-3">
                <div className={`w-10 h-10 rounded-xl ${kpi.bg} flex items-center justify-center`}>
                  <Icon className={`w-5 h-5 ${kpi.color}`} />
                </div>
              </div>
              <p className="text-2xl font-bold text-gray-900">
                {kpi.isCurrency ? formatCurrency(kpi.value) : formatNumber(kpi.value)}
              </p>
              <p className="text-xs text-gray-500 mt-0.5">{kpi.label}</p>
            </div>
          );
        })}
      </div>

      {/* Charts Row */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-4">
        {/* Growth Chart */}
        <div className="admin-card p-5 lg:col-span-2">
          <div className="flex items-center justify-between mb-5">
            <div>
              <p className="section-title">Platform Growth</p>
              <p className="section-subtitle">Users, products & rentals</p>
            </div>
          </div>
          <ResponsiveContainer width="100%" height={220}>
            <AreaChart data={stats.recentMonths}>
              <defs>
                <linearGradient id="usersGrad" x1="0" y1="0" x2="0" y2="1">
                  <stop offset="5%" stopColor="#7c3aed" stopOpacity={0.15} />
                  <stop offset="95%" stopColor="#7c3aed" stopOpacity={0} />
                </linearGradient>
                <linearGradient id="rentalsGrad" x1="0" y1="0" x2="0" y2="1">
                  <stop offset="5%" stopColor="#10b981" stopOpacity={0.15} />
                  <stop offset="95%" stopColor="#10b981" stopOpacity={0} />
                </linearGradient>
              </defs>
              <CartesianGrid strokeDasharray="3 3" stroke="#f3f4f6" />
              <XAxis dataKey="date" tick={{ fontSize: 12, fill: "#9ca3af" }} axisLine={false} tickLine={false} />
              <YAxis tick={{ fontSize: 12, fill: "#9ca3af" }} axisLine={false} tickLine={false} />
              <Tooltip contentStyle={{ borderRadius: 8, border: "1px solid #e5e7eb", fontSize: 12 }} />
              <Area type="monotone" dataKey="users" stroke="#7c3aed" strokeWidth={2} fill="url(#usersGrad)" name="Users" />
              <Area type="monotone" dataKey="rentals" stroke="#10b981" strokeWidth={2} fill="url(#rentalsGrad)" name="Rentals" />
              <Area type="monotone" dataKey="products" stroke="#f59e0b" strokeWidth={2} fill="none" strokeDasharray="4 4" name="Products" />
            </AreaChart>
          </ResponsiveContainer>
          <div className="flex items-center gap-5 mt-3 justify-center">
            {[["#7c3aed","Users"],["#10b981","Rentals"],["#f59e0b","Products"]].map(([c,l]) => (
              <div key={l} className="flex items-center gap-1.5 text-xs text-gray-500">
                <div className="w-2.5 h-2.5 rounded-full" style={{ background: c }} />
                {l}
              </div>
            ))}
          </div>
        </div>

        {/* Category Breakdown */}
        <div className="admin-card p-5">
          <p className="section-title mb-1">Category Split</p>
          <p className="section-subtitle mb-4">Listings by category</p>
          <ResponsiveContainer width="100%" height={180}>
            <PieChart>
              <Pie data={stats.categoryBreakdown} cx="50%" cy="50%" innerRadius={50} outerRadius={75} dataKey="value" paddingAngle={3}>
                {stats.categoryBreakdown.map((_: any, i: number) => (
                  <Cell key={i} fill={PIE_COLORS[i % PIE_COLORS.length]} />
                ))}
              </Pie>
              <Tooltip contentStyle={{ borderRadius: 8, border: "1px solid #e5e7eb", fontSize: 12 }} />
            </PieChart>
          </ResponsiveContainer>
          <div className="space-y-1.5 mt-2">
            {stats.categoryBreakdown.slice(0, 4).map((d: any, i: number) => (
              <div key={d.name} className="flex items-center justify-between text-xs">
                <div className="flex items-center gap-1.5">
                  <div className="w-2 h-2 rounded-full" style={{ background: PIE_COLORS[i] }} />
                  <span className="text-gray-600">{d.name}</span>
                </div>
                <span className="font-semibold text-gray-800">{d.value}</span>
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* Revenue + Quick Actions */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-4">
        {/* Revenue */}
        <div className="admin-card p-5 lg:col-span-2">
          <div className="flex items-center justify-between mb-5">
            <div>
              <p className="section-title">Monthly Revenue</p>
              <p className="section-subtitle">Total platform earnings</p>
            </div>
            <div className="text-right">
              <p className="text-xl font-bold text-gray-900">{formatCurrency(stats.monthlyRevenue)}</p>
            </div>
          </div>
          <ResponsiveContainer width="100%" height={180}>
            <BarChart data={stats.revenueByMonth} barSize={28}>
              <CartesianGrid strokeDasharray="3 3" stroke="#f3f4f6" vertical={false} />
              <XAxis dataKey="date" tick={{ fontSize: 12, fill: "#9ca3af" }} axisLine={false} tickLine={false} />
              <YAxis tick={{ fontSize: 12, fill: "#9ca3af" }} axisLine={false} tickLine={false} tickFormatter={(v) => `₹${(v/1000).toFixed(0)}k`} />
              <Tooltip contentStyle={{ borderRadius: 8, border: "1px solid #e5e7eb", fontSize: 12 }} formatter={(v: any) => [formatCurrency(v), "Revenue"]} />
              <Bar dataKey="revenue" fill="#7c3aed" radius={[6,6,0,0]} />
            </BarChart>
          </ResponsiveContainer>
        </div>

        {/* Quick Actions */}
        <div className="admin-card p-5">
          <p className="section-title mb-1">Quick Actions</p>
          <p className="section-subtitle mb-4">Items needing attention</p>
          <div className="space-y-2">
            {quickActions.map((action) => {
              const Icon = action.icon;
              return (
                <Link
                  key={action.href}
                  href={action.href}
                  className="flex items-center gap-3 p-3 rounded-xl hover:bg-gray-50 transition-colors group"
                >
                  <div className={`w-9 h-9 rounded-xl ${action.bg} flex items-center justify-center flex-shrink-0`}>
                    <Icon className={`w-4.5 h-4.5 ${action.color}`} size={18} />
                  </div>
                  <div className="flex-1 min-w-0">
                    <p className="text-sm font-medium text-gray-800">{action.label}</p>
                    <p className="text-xs text-gray-400">{stats[action.key] || 0} items</p>
                  </div>
                  <ArrowRight size={14} className="text-gray-300 group-hover:text-gray-500 transition-colors" />
                </Link>
              );
            })}
          </div>
        </div>
      </div>

      {/* Bottom Row: Recent Rentals + Recent Reports + Activity */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-4">
        {/* Recent Rentals */}
        <div className="admin-card lg:col-span-2">
          <div className="flex items-center justify-between px-5 py-4 border-b border-gray-50">
            <p className="section-title">Recent Rentals</p>
            <Link href="/rentals" className="text-xs text-purple-600 hover:underline font-medium">View all</Link>
          </div>
          <div className="overflow-x-auto">
            <table className="data-table">
              <thead>
                <tr>
                  <th>Product</th>
                  <th>Renter</th>
                  <th>Dates</th>
                  <th>Amount</th>
                  <th>Status</th>
                </tr>
              </thead>
              <tbody>
                {rentals.map((rental) => (
                  <tr key={rental.id}>
                    <td className="font-medium text-gray-800">{rental.product.name}</td>
                    <td className="text-gray-600">{rental.rentedBy.name}</td>
                    <td className="text-gray-500 text-xs">
                      {new Date(rental.startDate).toLocaleDateString("en-IN", { day: "numeric", month: "short" })}
                      {" – "}
                      {new Date(rental.endDate).toLocaleDateString("en-IN", { day: "numeric", month: "short" })}
                    </td>
                    <td className="font-semibold text-gray-800">{formatCurrency(rental.totalPrice)}</td>
                    <td>
                      <span className={`badge ${rentalStatusColors[rental.status] || 'badge-gray'}`}>
                        {rental.status}
                      </span>
                    </td>
                  </tr>
                ))}
                {rentals.length === 0 && (
                  <tr><td colSpan={5} className="text-center text-gray-500 py-4">No recent rentals</td></tr>
                )}
              </tbody>
            </table>
          </div>
        </div>

        {/* Recent Activity */}
        <div className="admin-card">
          <div className="flex items-center justify-between px-5 py-4 border-b border-gray-50">
            <p className="section-title">Activity Feed</p>
            <Link href="/audit-logs" className="text-xs text-purple-600 hover:underline font-medium">View all</Link>
          </div>
          <div className="px-5 py-3 space-y-3 max-h-72 overflow-y-auto">
            {logs.map((log) => (
              <div key={log.id} className="flex items-start gap-3">
                <div className="w-1.5 h-1.5 rounded-full bg-purple-400 mt-2 flex-shrink-0" />
                <div className="min-w-0">
                  <p className="text-xs text-gray-700">
                    <span className="font-medium">{log.adminName}</span>{" "}
                    {log.action.replace(/_/g, " ")} —{" "}
                    <span className="text-purple-600">{log.entityName || log.entityId || log.entity}</span>
                  </p>
                  <p className="text-[10px] text-gray-400 mt-0.5">{formatRelativeTime(log.createdAt)}</p>
                </div>
              </div>
            ))}
            {logs.length === 0 && (
              <p className="text-center text-gray-500 text-sm py-4">No recent activity</p>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}
