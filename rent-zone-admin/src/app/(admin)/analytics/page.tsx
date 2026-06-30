"use client";

import { useState, useEffect } from "react";
import {
  Users, Package, CalendarCheck, Star, MessageSquare, Wand2, Flag, IndianRupee,
} from "lucide-react";
import {
  BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer,
  PieChart, Pie, Cell,
} from "recharts";
import { adminService } from "@/services/admin";
import { formatCurrency, formatNumber } from "@/lib/utils";

const PIE_COLORS = ["#7c3aed", "#a855f7", "#c084fc", "#6366f1", "#818cf8", "#93c5fd"];

export default function AnalyticsPage() {
  const [stats, setStats] = useState<any>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchStats = async () => {
      try {
        const res = await adminService.dashboard.getStats();
        setStats(res);
      } catch (err) {
        console.error(err);
      } finally {
        setLoading(false);
      }
    };
    fetchStats();
  }, []);

  if (loading) {
    return <div className="flex items-center justify-center min-h-[500px]"><div className="w-8 h-8 border-4 border-purple-500 border-t-transparent rounded-full animate-spin"></div></div>;
  }

  if (!stats) return <div>Failed to load analytics.</div>;

  const summaryCards = [
    { label: "Total Users", value: stats.totalUsers, icon: Users, color: "text-purple-600", bg: "bg-purple-50" },
    { label: "Active Users", value: stats.activeUsers, icon: Users, color: "text-green-600", bg: "bg-green-50" },
    { label: "Total Products", value: stats.totalProducts, icon: Package, color: "text-violet-600", bg: "bg-violet-50" },
    { label: "Total Rentals", value: stats.totalRentals, icon: CalendarCheck, color: "text-indigo-600", bg: "bg-indigo-50" },
    { label: "Active Rentals", value: stats.activeRentals, icon: CalendarCheck, color: "text-blue-600", bg: "bg-blue-50" },
    { label: "Completed", value: stats.completedRentals, icon: CalendarCheck, color: "text-emerald-600", bg: "bg-emerald-50" },
    { label: "Revenue", value: stats.monthlyRevenue, icon: IndianRupee, color: "text-emerald-600", bg: "bg-emerald-50", isCurrency: true },
    { label: "Pending Reports", value: stats.pendingReports, icon: Flag, color: "text-red-500", bg: "bg-red-50" },
    { label: "Total Reviews", value: stats.totalReviews, icon: Star, color: "text-amber-500", bg: "bg-amber-50" },
    { label: "Total Chats", value: stats.totalChats, icon: MessageSquare, color: "text-blue-600", bg: "bg-blue-50" },
    { label: "Try-Ons", value: stats.totalTryOns, icon: Wand2, color: "text-pink-600", bg: "bg-pink-50" },
  ];

  return (
    <div className="space-y-6">
      <div>
        <h2 className="text-2xl font-bold text-gray-900">Analytics & Reports</h2>
        <p className="text-sm text-gray-500 mt-1">Full platform analytics overview.</p>
      </div>

      {/* Summary Cards */}
      <div className="grid grid-cols-2 md:grid-cols-4 lg:grid-cols-6 gap-3">
        {summaryCards.map((card) => {
          const Icon = card.icon;
          return (
            <div key={card.label} className="admin-card p-4">
              <div className={`w-8 h-8 rounded-lg ${card.bg} flex items-center justify-center mb-2`}>
                <Icon className={`w-4 h-4 ${card.color}`} />
              </div>
              <p className="text-lg font-bold text-gray-900">
                {card.isCurrency ? formatCurrency(card.value) : formatNumber(card.value)}
              </p>
              <p className="text-xs text-gray-500">{card.label}</p>
            </div>
          );
        })}
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-4">
        {/* Revenue Chart */}
        <div className="admin-card p-5">
          <p className="section-title mb-1">Revenue</p>
          <p className="section-subtitle mb-4">Platform earnings</p>
          <ResponsiveContainer width="100%" height={250}>
            <BarChart data={stats.revenueByMonth} barSize={32}>
              <CartesianGrid strokeDasharray="3 3" stroke="#f3f4f6" vertical={false} />
              <XAxis dataKey="date" tick={{ fontSize: 12, fill: "#9ca3af" }} axisLine={false} tickLine={false} />
              <YAxis tick={{ fontSize: 12, fill: "#9ca3af" }} axisLine={false} tickLine={false} tickFormatter={(v) => `₹${(v/1000).toFixed(0)}k`} />
              <Tooltip contentStyle={{ borderRadius: 8, border: "1px solid #e5e7eb", fontSize: 12 }} formatter={(v: any) => [formatCurrency(v), "Revenue"]} />
              <Bar dataKey="revenue" fill="#7c3aed" radius={[6,6,0,0]} />
            </BarChart>
          </ResponsiveContainer>
        </div>

        {/* Category Split */}
        <div className="admin-card p-5">
          <p className="section-title mb-1">Category Distribution</p>
          <p className="section-subtitle mb-4">Products by category</p>
          <ResponsiveContainer width="100%" height={250}>
            <PieChart>
              <Pie data={stats.categoryBreakdown} cx="50%" cy="50%" innerRadius={60} outerRadius={90} dataKey="value" paddingAngle={3} label={({ name, value }: any) => `${name}: ${value}`}>
                {stats.categoryBreakdown.map((_: any, i: number) => (
                  <Cell key={i} fill={PIE_COLORS[i % PIE_COLORS.length]} />
                ))}
              </Pie>
              <Tooltip contentStyle={{ borderRadius: 8, border: "1px solid #e5e7eb", fontSize: 12 }} />
            </PieChart>
          </ResponsiveContainer>
        </div>
      </div>
    </div>
  );
}
