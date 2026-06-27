"use client";

import { use } from "react";
import Link from "next/link";
import { ArrowLeft, CheckCircle, XCircle, Ban, Shield, UserCheck, Package, Star, CalendarCheck, Flag, MapPin, Phone, GraduationCap, Calendar } from "lucide-react";
import { mockUsers, mockProducts, mockRentals, mockReports, mockReviews, mockTryOns } from "@/lib/mock-data";
import { formatDate, formatDateTime, getInitials, userStatusColors, rentalStatusColors, cn } from "@/lib/utils";

export default function UserDetailPage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = use(params);
  const user = mockUsers.find((u) => u.id === id) ?? mockUsers[0];
  const userProducts = mockProducts.filter((p) => p.listedByUserId === user.id);
  const userRentals = mockRentals.filter((r) => r.rentedByUserId === user.id || r.rentedFromUserId === user.id);
  const userReports = mockReports.filter((r) => r.reportedUserId === user.id);
  const userReviews = mockReviews.filter((r) => r.userId === user.id);
  const userTryOns = mockTryOns.filter((t) => t.userId === user.id);

  const timeline = [
    { label: "Account created", date: user.createdAt, icon: "✦", color: "text-purple-500" },
    ...userRentals.map((r) => ({ label: `Rental: ${r.product.name}`, date: r.createdAt, icon: "📦", color: "text-blue-500" })),
    ...userReports.map((r) => ({ label: `Reported for ${r.reason}`, date: r.createdAt, icon: "⚑", color: "text-red-500" })),
  ].sort((a, b) => new Date(b.date).getTime() - new Date(a.date).getTime());

  return (
    <div className="space-y-5 max-w-[1200px]">
      {/* Back */}
      <Link href="/users" className="inline-flex items-center gap-2 text-sm text-gray-500 hover:text-purple-600 transition-colors">
        <ArrowLeft size={15} /> Back to Users
      </Link>

      {/* Profile Header */}
      <div className="admin-card p-6">
        <div className="flex items-start justify-between flex-wrap gap-4">
          <div className="flex items-center gap-4">
            <div className="w-16 h-16 rounded-2xl bg-gradient-to-br from-purple-500 to-violet-600 flex items-center justify-center text-white text-2xl font-bold shadow-lg">
              {getInitials(user.name)}
            </div>
            <div>
              <div className="flex items-center gap-2">
                <h2 className="text-xl font-bold text-gray-900">{user.name}</h2>
                {user.isVerified
                  ? <CheckCircle size={16} className="text-emerald-500" />
                  : <XCircle size={16} className="text-gray-300" />
                }
              </div>
              <p className="text-sm text-gray-500">{user.email}</p>
              <div className="flex items-center gap-3 mt-2">
                <span className={`badge ${userStatusColors[user.status]}`}>{user.status}</span>
                <span className="badge badge-gray">{user.provider}</span>
                {user.preferredCategory && (
                  <span className="badge badge-purple">{user.preferredCategory}</span>
                )}
              </div>
            </div>
          </div>

          {/* Actions */}
          <div className="flex items-center gap-2 flex-wrap">
            {!user.isVerified && (
              <button className="btn-secondary text-xs py-1.5 gap-1.5">
                <UserCheck size={14} /> Verify User
              </button>
            )}
            {user.status === "active" && (
              <button className="btn-secondary text-xs py-1.5 gap-1.5 text-amber-600 border-amber-200 hover:bg-amber-50">
                <Ban size={14} /> Suspend
              </button>
            )}
            {user.status !== "banned" && (
              <button className="btn-danger text-xs py-1.5">
                <Shield size={14} /> Ban User
              </button>
            )}
            {user.status !== "active" && (
              <button className="btn-secondary text-xs py-1.5 gap-1.5 text-emerald-600 border-emerald-200 hover:bg-emerald-50">
                <CheckCircle size={14} /> Restore
              </button>
            )}
          </div>
        </div>

        {/* Info grid */}
        <div className="grid grid-cols-2 md:grid-cols-4 gap-4 mt-6 pt-6 border-t border-gray-50">
          {[
            { label: "Location", value: user.location, icon: MapPin },
            { label: "Phone", value: user.phoneNumber ?? "Not provided", icon: Phone },
            { label: "University", value: user.university ?? "Not provided", icon: GraduationCap },
            { label: "Joined", value: formatDate(user.createdAt), icon: Calendar },
          ].map((item) => (
            <div key={item.label} className="flex items-start gap-2.5">
              <item.icon size={15} className="text-gray-400 mt-0.5" />
              <div>
                <p className="text-xs text-gray-400">{item.label}</p>
                <p className="text-sm font-medium text-gray-700 mt-0.5">{item.value}</p>
              </div>
            </div>
          ))}
        </div>

        {/* Stat cards */}
        <div className="grid grid-cols-2 md:grid-cols-4 gap-3 mt-4">
          {[
            { label: "Listings", value: user._count.products, icon: Package, color: "text-purple-600", bg: "bg-purple-50" },
            { label: "Rentals", value: user._count.rentals, icon: CalendarCheck, color: "text-blue-600", bg: "bg-blue-50" },
            { label: "Reviews", value: user._count.reviews, icon: Star, color: "text-amber-500", bg: "bg-amber-50" },
            { label: "Reports", value: user._count.reports, icon: Flag, color: "text-red-500", bg: "bg-red-50" },
          ].map((s) => (
            <div key={s.label} className="flex items-center gap-3 p-3 rounded-xl bg-gray-50">
              <div className={`w-9 h-9 rounded-xl ${s.bg} flex items-center justify-center`}>
                <s.icon className={`w-4 h-4 ${s.color}`} />
              </div>
              <div>
                <p className="text-lg font-bold text-gray-900">{s.value}</p>
                <p className="text-xs text-gray-500">{s.label}</p>
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* Tabs content */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-4">
        {/* Listings */}
        <div className="admin-card lg:col-span-2">
          <div className="px-5 py-4 border-b border-gray-50">
            <p className="section-title">Listings ({userProducts.length})</p>
          </div>
          {userProducts.length === 0 ? (
            <div className="empty-state py-10">
              <p className="text-sm text-gray-400">No listings yet</p>
            </div>
          ) : (
            <div className="overflow-x-auto">
              <table className="data-table">
                <thead>
                  <tr><th>Name</th><th>Category</th><th>Price/day</th><th>Rating</th><th>Status</th></tr>
                </thead>
                <tbody>
                  {userProducts.map((p) => (
                    <tr key={p.id}>
                      <td className="font-medium text-gray-800">{p.name}</td>
                      <td className="text-gray-500">{p.category.name}</td>
                      <td className="font-semibold text-gray-800">₹{p.rentPricePerDay}</td>
                      <td className="flex items-center gap-1 text-amber-500"><Star size={12} />{p.rating}</td>
                      <td><span className={`badge ${p.status === "active" ? "badge-green" : p.status === "featured" ? "badge-purple" : "badge-gray"}`}>{p.status}</span></td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          )}
        </div>

        {/* Activity Timeline */}
        <div className="admin-card">
          <div className="px-5 py-4 border-b border-gray-50">
            <p className="section-title">Activity Timeline</p>
          </div>
          <div className="px-5 py-4 space-y-3 max-h-80 overflow-y-auto">
            {timeline.slice(0, 10).map((item, i) => (
              <div key={i} className="flex items-start gap-3">
                <span className="text-base mt-0.5">{item.icon}</span>
                <div>
                  <p className="text-xs font-medium text-gray-700">{item.label}</p>
                  <p className="text-[10px] text-gray-400 mt-0.5">{formatDateTime(item.date)}</p>
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* Reports received */}
      {userReports.length > 0 && (
        <div className="admin-card">
          <div className="px-5 py-4 border-b border-gray-50">
            <p className="section-title text-red-600">Reports Against This User ({userReports.length})</p>
          </div>
          <div className="overflow-x-auto">
            <table className="data-table">
              <thead><tr><th>Reason</th><th>Reporter</th><th>Description</th><th>Status</th><th>Date</th></tr></thead>
              <tbody>
                {userReports.map((r) => (
                  <tr key={r.id}>
                    <td><span className="badge badge-red capitalize">{r.reason}</span></td>
                    <td className="text-gray-700">{r.reporter.name}</td>
                    <td className="text-gray-500 text-xs max-w-[300px] truncate">{r.description ?? "—"}</td>
                    <td><span className={`badge ${r.status === "pending" ? "badge-yellow" : r.status === "valid" ? "badge-red" : "badge-gray"}`}>{r.status}</span></td>
                    <td className="text-gray-500 text-xs">{formatDate(r.createdAt)}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      )}
    </div>
  );
}
