"use client";

import { useState } from "react";
import { Download, TrendingUp, TrendingDown, Calendar } from "lucide-react";
import {
  AreaChart, Area, BarChart, Bar, LineChart, Line, PieChart, Pie, Cell,
  XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, Legend,
} from "recharts";
import { mockAnalyticsData, mockRevenueData, mockCategoryData } from "@/lib/mock-data";
import { formatCurrency, cn } from "@/lib/utils";

const DATE_RANGES = ["7 Days", "30 Days", "3 Months", "6 Months", "1 Year"];
const PIE_COLORS = ["#7c3aed", "#a855f7", "#c084fc", "#6366f1", "#818cf8", "#93c5fd"];

const summaryCards = [
  { label: "Total Revenue", value: "₹8.45L", trend: +22.3, color: "text-emerald-600", bg: "bg-emerald-50" },
  { label: "Avg. Rental Value", value: "₹2,100", trend: +5.8, color: "text-purple-600", bg: "bg-purple-50" },
  { label: "Conversion Rate", value: "68.4%", trend: +3.2, color: "text-blue-600", bg: "bg-blue-50" },
  { label: "Avg. Review Score", value: "4.6 ⭐", trend: +0.3, color: "text-amber-600", bg: "bg-amber-50" },
];

export default function AnalyticsPage() {
  const [dateRange, setDateRange] = useState("6 Months");

  return (
    <div className="space-y-5 max-w-[1400px]">
      {/* Header */}
      <div className="flex items-center justify-between flex-wrap gap-3">
        <div>
          <h2 className="text-xl font-bold text-gray-900">Analytics & Reports</h2>
          <p className="text-sm text-gray-500">Platform-wide metrics and growth trends</p>
        </div>
        <div className="flex items-center gap-3">
          <div className="flex gap-1 bg-gray-100 p-1 rounded-lg">
            {DATE_RANGES.map((r) => (
              <button key={r} onClick={() => setDateRange(r)}
                className={cn("px-3 py-1.5 rounded-md text-xs font-medium transition-colors", dateRange === r ? "bg-white text-purple-700 shadow-sm" : "text-gray-500 hover:text-gray-700")}>
                {r}
              </button>
            ))}
          </div>
          <button className="btn-secondary text-xs py-2"><Download size={14} /> Export CSV</button>
          <button className="btn-secondary text-xs py-2"><Download size={14} /> Export PDF</button>
        </div>
      </div>

      {/* Summary Cards */}
      <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
        {summaryCards.map((card) => (
          <div key={card.label} className="admin-card p-5">
            <p className="text-xs text-gray-500 mb-2">{card.label}</p>
            <p className="text-2xl font-bold text-gray-900">{card.value}</p>
            <div className="flex items-center gap-1 mt-2">
              {card.trend > 0 ? <TrendingUp size={13} className="text-emerald-500" /> : <TrendingDown size={13} className="text-red-400" />}
              <span className={cn("text-xs font-medium", card.trend > 0 ? "text-emerald-600" : "text-red-500")}>
                {card.trend > 0 ? "+" : ""}{card.trend}% vs prev period
              </span>
            </div>
          </div>
        ))}
      </div>

      {/* Revenue Chart */}
      <div className="admin-card p-5">
        <div className="flex items-center justify-between mb-5">
          <div>
            <p className="section-title">Revenue Over Time</p>
            <p className="section-subtitle">Monthly earnings from rentals</p>
          </div>
        </div>
        <ResponsiveContainer width="100%" height={260}>
          <AreaChart data={mockRevenueData}>
            <defs>
              <linearGradient id="revGrad" x1="0" y1="0" x2="0" y2="1">
                <stop offset="5%" stopColor="#7c3aed" stopOpacity={0.15} />
                <stop offset="95%" stopColor="#7c3aed" stopOpacity={0} />
              </linearGradient>
            </defs>
            <CartesianGrid strokeDasharray="3 3" stroke="#f3f4f6" />
            <XAxis dataKey="date" tick={{ fontSize: 12, fill: "#9ca3af" }} axisLine={false} tickLine={false} />
            <YAxis tick={{ fontSize: 12, fill: "#9ca3af" }} axisLine={false} tickLine={false} tickFormatter={(v) => `₹${(v/1000).toFixed(0)}k`} />
            <Tooltip contentStyle={{ borderRadius: 8, border: "1px solid #e5e7eb", fontSize: 12 }} formatter={(v: any) => [formatCurrency(v), "Revenue"]} />
            <Area type="monotone" dataKey="revenue" stroke="#7c3aed" strokeWidth={2.5} fill="url(#revGrad)" />
          </AreaChart>
        </ResponsiveContainer>
      </div>

      {/* Platform Growth + Category Breakdown */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-4">
        {/* Growth */}
        <div className="admin-card p-5">
          <p className="section-title mb-1">Platform Growth</p>
          <p className="section-subtitle mb-5">Users, rentals, reviews</p>
          <ResponsiveContainer width="100%" height={220}>
            <LineChart data={mockAnalyticsData}>
              <CartesianGrid strokeDasharray="3 3" stroke="#f3f4f6" />
              <XAxis dataKey="date" tick={{ fontSize: 12, fill: "#9ca3af" }} axisLine={false} tickLine={false} />
              <YAxis tick={{ fontSize: 12, fill: "#9ca3af" }} axisLine={false} tickLine={false} />
              <Tooltip contentStyle={{ borderRadius: 8, border: "1px solid #e5e7eb", fontSize: 12 }} />
              <Line type="monotone" dataKey="users" stroke="#7c3aed" strokeWidth={2} dot={false} name="Users" />
              <Line type="monotone" dataKey="rentals" stroke="#10b981" strokeWidth={2} dot={false} name="Rentals" />
              <Line type="monotone" dataKey="reviews" stroke="#f59e0b" strokeWidth={2} dot={false} name="Reviews" />
              <Legend />
            </LineChart>
          </ResponsiveContainer>
        </div>

        {/* Reports & TryOns */}
        <div className="admin-card p-5">
          <p className="section-title mb-1">Reports & Try-Ons</p>
          <p className="section-subtitle mb-5">Moderation load and try-on usage</p>
          <ResponsiveContainer width="100%" height={220}>
            <BarChart data={mockAnalyticsData} barGap={4}>
              <CartesianGrid strokeDasharray="3 3" stroke="#f3f4f6" vertical={false} />
              <XAxis dataKey="date" tick={{ fontSize: 12, fill: "#9ca3af" }} axisLine={false} tickLine={false} />
              <YAxis tick={{ fontSize: 12, fill: "#9ca3af" }} axisLine={false} tickLine={false} />
              <Tooltip contentStyle={{ borderRadius: 8, border: "1px solid #e5e7eb", fontSize: 12 }} />
              <Bar dataKey="reports" fill="#ef4444" radius={[4,4,0,0]} name="Reports" barSize={16} />
              <Bar dataKey="tryOns" fill="#7c3aed" radius={[4,4,0,0]} name="Try-Ons" barSize={16} />
              <Legend />
            </BarChart>
          </ResponsiveContainer>
        </div>
      </div>

      {/* Category Breakdown Table */}
      <div className="admin-card">
        <div className="px-5 py-4 border-b border-gray-50">
          <p className="section-title">Category Breakdown</p>
        </div>
        <div className="overflow-x-auto">
          <table className="data-table">
            <thead>
              <tr><th>Category</th><th>Type</th><th>Listings</th><th>Share</th><th>Trend</th></tr>
            </thead>
            <tbody>
              {mockCategoryData.map((cat, i) => {
                const total = mockCategoryData.reduce((s, c) => s + c.value, 0);
                const share = ((cat.value / total) * 100).toFixed(1);
                return (
                  <tr key={cat.name}>
                    <td>
                      <div className="flex items-center gap-2">
                        <div className="w-2.5 h-2.5 rounded-full" style={{ background: PIE_COLORS[i] }} />
                        {cat.name.replace(/ \(.\)/, "")}
                      </div>
                    </td>
                    <td><span className="badge badge-purple">{cat.name.includes("(W)") ? "Women" : "Men"}</span></td>
                    <td className="font-semibold text-gray-800">{cat.value}</td>
                    <td>
                      <div className="flex items-center gap-2">
                        <div className="flex-1 h-1.5 bg-gray-100 rounded-full max-w-[80px]">
                          <div className="h-full rounded-full" style={{ width: `${share}%`, background: PIE_COLORS[i] }} />
                        </div>
                        <span className="text-xs text-gray-600 w-8">{share}%</span>
                      </div>
                    </td>
                    <td><span className="stat-up">↑ 8.2%</span></td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}
