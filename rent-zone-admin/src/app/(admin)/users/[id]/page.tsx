"use client";

import { use, useEffect, useState } from "react";
import Link from "next/link";
import { ArrowLeft, CheckCircle, XCircle, Ban, Shield, UserCheck, Package, Star, CalendarCheck, Flag, MapPin, Phone, GraduationCap, Calendar } from "lucide-react";
import { adminService } from "@/services/admin";
import { formatDate, formatDateTime, getInitials, userStatusColors, rentalStatusColors, cn } from "@/lib/utils";

export default function UserDetailPage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = use(params);
  const [user, setUser] = useState<any>(null);
  const [loading, setLoading] = useState(true);

  const fetchUser = async () => {
    try {
      const res = await adminService.users.get(id);
      setUser(res);
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchUser();
  }, [id]);

  const handleAction = async (action: "verify" | "suspend" | "ban" | "restore") => {
    try {
      await adminService.users[action](id);
      fetchUser();
    } catch (err) {
      console.error(err);
    }
  };

  if (loading) {
    return <div className="flex justify-center py-20"><div className="w-8 h-8 border-4 border-purple-500 border-t-transparent rounded-full animate-spin"></div></div>;
  }

  if (!user) {
    return <div className="py-20 text-center text-gray-500">User not found</div>;
  }

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
              <p className="text-sm text-gray-500">{user.account?.email}</p>
              <div className="flex items-center gap-3 mt-2">
                <span className={`badge ${userStatusColors[user.status] || 'badge-gray'}`}>{user.status}</span>
                <span className="badge badge-gray">{user.account?.provider}</span>
                {user.preferredCategory && (
                  <span className="badge badge-purple">{user.preferredCategory}</span>
                )}
              </div>
            </div>
          </div>

          {/* Actions */}
          <div className="flex items-center gap-2 flex-wrap">
            {!user.isVerified && (
              <button onClick={() => handleAction("verify")} className="btn-secondary text-xs py-1.5 gap-1.5">
                <UserCheck size={14} /> Verify User
              </button>
            )}
            {user.status === "active" && (
              <button onClick={() => handleAction("suspend")} className="btn-secondary text-xs py-1.5 gap-1.5 text-amber-600 border-amber-200 hover:bg-amber-50">
                <Ban size={14} /> Suspend
              </button>
            )}
            {user.status !== "banned" && (
              <button onClick={() => handleAction("ban")} className="btn-danger text-xs py-1.5 gap-1.5">
                <Shield size={14} /> Ban User
              </button>
            )}
            {user.status !== "active" && (
              <button onClick={() => handleAction("restore")} className="btn-secondary text-xs py-1.5 gap-1.5 text-emerald-600 border-emerald-200 hover:bg-emerald-50">
                <CheckCircle size={14} /> Restore
              </button>
            )}
          </div>
        </div>

        {/* Info grid */}
        <div className="grid grid-cols-2 md:grid-cols-4 gap-4 mt-6 pt-6 border-t border-gray-50">
          {[
            { label: "Location", value: user.location, icon: MapPin },
            { label: "Phone", value: user.phoneNumber || "Not provided", icon: Phone },
            { label: "University", value: user.university || "Not provided", icon: GraduationCap },
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
            { label: "Listings", value: user._count?.products || 0, icon: Package, color: "text-purple-600", bg: "bg-purple-50" },
            { label: "Rentals", value: user._count?.rentalsAsRenter || 0, icon: CalendarCheck, color: "text-blue-600", bg: "bg-blue-50" },
            { label: "Reviews", value: user._count?.reviews || 0, icon: Star, color: "text-amber-500", bg: "bg-amber-50" },
            { label: "Reports", value: user._count?.reportsReceived || 0, icon: Flag, color: "text-red-500", bg: "bg-red-50" },
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
    </div>
  );
}
