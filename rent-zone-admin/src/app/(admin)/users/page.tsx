"use client";

import { useState } from "react";
import { Search, Filter, Plus, MoreHorizontal, Eye, Ban, CheckCircle, XCircle, Trash2, Shield, UserCheck } from "lucide-react";
import Link from "next/link";
import { mockUsers } from "@/lib/mock-data";
import { formatDate, formatRelativeTime, getInitials, userStatusColors, cn } from "@/lib/utils";
import type { User } from "@/types";

type StatusFilter = "all" | "active" | "suspended" | "banned";
type VerifiedFilter = "all" | "verified" | "unverified";

export default function UsersPage() {
  const [search, setSearch] = useState("");
  const [statusFilter, setStatusFilter] = useState<StatusFilter>("all");
  const [verifiedFilter, setVerifiedFilter] = useState<VerifiedFilter>("all");
  const [selectedRows, setSelectedRows] = useState<string[]>([]);
  const [users, setUsers] = useState<User[]>(mockUsers);

  const filtered = users.filter((u) => {
    const q = search.toLowerCase();
    const matchSearch = u.name.toLowerCase().includes(q) || u.email.toLowerCase().includes(q) || u.location.toLowerCase().includes(q);
    const matchStatus = statusFilter === "all" || u.status === statusFilter;
    const matchVerified = verifiedFilter === "all" || (verifiedFilter === "verified" ? u.isVerified : !u.isVerified);
    return matchSearch && matchStatus && matchVerified;
  });

  const toggleRow = (id: string) =>
    setSelectedRows((prev) => prev.includes(id) ? prev.filter((r) => r !== id) : [...prev, id]);
  const toggleAll = () =>
    setSelectedRows(selectedRows.length === filtered.length ? [] : filtered.map((u) => u.id));

  const handleAction = (userId: string, action: string) => {
    setUsers((prev) => prev.map((u) => {
      if (u.id !== userId) return u;
      if (action === "verify") return { ...u, isVerified: true };
      if (action === "unverify") return { ...u, isVerified: false };
      if (action === "suspend") return { ...u, status: "suspended" };
      if (action === "ban") return { ...u, status: "banned" };
      if (action === "restore") return { ...u, status: "active" };
      return u;
    }));
  };

  return (
    <div className="space-y-5 max-w-[1400px]">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h2 className="text-xl font-bold text-gray-900">Users</h2>
          <p className="text-sm text-gray-500">{users.length} total users on the platform</p>
        </div>
        <button className="btn-primary">
          <Plus size={15} /> Invite Admin
        </button>
      </div>

      {/* Filters */}
      <div className="admin-card p-4">
        <div className="flex flex-wrap gap-3 items-center">
          <div className="relative flex-1 min-w-[200px]">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400 w-4 h-4" />
            <input
              type="text"
              placeholder="Search by name, email, location..."
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              className="form-input pl-9"
            />
          </div>
          <select value={statusFilter} onChange={(e) => setStatusFilter(e.target.value as StatusFilter)} className="form-select w-auto">
            <option value="all">All Status</option>
            <option value="active">Active</option>
            <option value="suspended">Suspended</option>
            <option value="banned">Banned</option>
          </select>
          <select value={verifiedFilter} onChange={(e) => setVerifiedFilter(e.target.value as VerifiedFilter)} className="form-select w-auto">
            <option value="all">All Verification</option>
            <option value="verified">Verified</option>
            <option value="unverified">Unverified</option>
          </select>
          {selectedRows.length > 0 && (
            <div className="flex items-center gap-2 ml-auto">
              <span className="text-xs text-gray-500">{selectedRows.length} selected</span>
              <button className="btn-secondary text-xs py-1.5">Bulk Suspend</button>
              <button className="btn-danger text-xs py-1.5">Bulk Ban</button>
            </div>
          )}
        </div>
      </div>

      {/* Table */}
      <div className="admin-card overflow-hidden">
        {filtered.length === 0 ? (
          <div className="empty-state">
            <div className="empty-state-icon"><Search size={24} /></div>
            <p className="text-sm font-medium text-gray-700">No users found</p>
            <p className="text-xs text-gray-400 mt-1">Try adjusting your search or filters</p>
          </div>
        ) : (
          <div className="overflow-x-auto">
            <table className="data-table">
              <thead>
                <tr>
                  <th className="w-10">
                    <input type="checkbox" checked={selectedRows.length === filtered.length && filtered.length > 0} onChange={toggleAll} className="rounded" />
                  </th>
                  <th>User</th>
                  <th>Location</th>
                  <th>Provider</th>
                  <th>Listings</th>
                  <th>Rentals</th>
                  <th>Verified</th>
                  <th>Status</th>
                  <th>Joined</th>
                  <th></th>
                </tr>
              </thead>
              <tbody>
                {filtered.map((user) => (
                  <tr key={user.id}>
                    <td>
                      <input type="checkbox" checked={selectedRows.includes(user.id)} onChange={() => toggleRow(user.id)} className="rounded" />
                    </td>
                    <td>
                      <div className="flex items-center gap-3">
                        <div className="w-8 h-8 rounded-full bg-gradient-to-br from-purple-400 to-violet-500 flex items-center justify-center text-white text-xs font-semibold flex-shrink-0">
                          {getInitials(user.name)}
                        </div>
                        <div>
                          <p className="font-medium text-gray-800 text-sm">{user.name}</p>
                          <p className="text-xs text-gray-400">{user.email}</p>
                        </div>
                      </div>
                    </td>
                    <td className="text-gray-600 text-sm">{user.location}</td>
                    <td>
                      <span className={cn("badge", user.provider === "google" ? "badge-blue" : user.provider === "apple" ? "badge-gray" : "badge-purple")}>
                        {user.provider}
                      </span>
                    </td>
                    <td className="text-gray-700 font-medium">{user._count.products}</td>
                    <td className="text-gray-700 font-medium">{user._count.rentals}</td>
                    <td>
                      {user.isVerified
                        ? <span className="flex items-center gap-1 text-emerald-600 text-xs font-medium"><CheckCircle size={13} /> Verified</span>
                        : <span className="flex items-center gap-1 text-gray-400 text-xs"><XCircle size={13} /> Not verified</span>
                      }
                    </td>
                    <td>
                      <span className={`badge ${userStatusColors[user.status]}`}>{user.status}</span>
                    </td>
                    <td className="text-gray-500 text-xs">{formatDate(user.createdAt)}</td>
                    <td>
                      <div className="flex items-center gap-1">
                        <Link href={`/users/${user.id}`} className="p-1.5 rounded-lg hover:bg-purple-50 text-gray-400 hover:text-purple-600 transition-colors" title="View">
                          <Eye size={15} />
                        </Link>
                        {!user.isVerified && (
                          <button onClick={() => handleAction(user.id, "verify")} className="p-1.5 rounded-lg hover:bg-emerald-50 text-gray-400 hover:text-emerald-600 transition-colors" title="Verify">
                            <UserCheck size={15} />
                          </button>
                        )}
                        {user.status === "active" && (
                          <button onClick={() => handleAction(user.id, "suspend")} className="p-1.5 rounded-lg hover:bg-amber-50 text-gray-400 hover:text-amber-600 transition-colors" title="Suspend">
                            <Ban size={15} />
                          </button>
                        )}
                        {user.status !== "banned" && (
                          <button onClick={() => handleAction(user.id, "ban")} className="p-1.5 rounded-lg hover:bg-red-50 text-gray-400 hover:text-red-500 transition-colors" title="Ban">
                            <Shield size={15} />
                          </button>
                        )}
                        {user.status !== "active" && (
                          <button onClick={() => handleAction(user.id, "restore")} className="p-1.5 rounded-lg hover:bg-emerald-50 text-gray-400 hover:text-emerald-600 transition-colors" title="Restore">
                            <CheckCircle size={15} />
                          </button>
                        )}
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>

      {/* Pagination */}
      <div className="flex items-center justify-between text-sm text-gray-500">
        <p>Showing {filtered.length} of {users.length} users</p>
        <div className="flex items-center gap-1">
          {["1","2","3"].map((p) => (
            <button key={p} className={cn("w-8 h-8 rounded-lg text-sm font-medium transition-colors", p === "1" ? "bg-purple-600 text-white" : "hover:bg-gray-100 text-gray-600")}>
              {p}
            </button>
          ))}
        </div>
      </div>
    </div>
  );
}
