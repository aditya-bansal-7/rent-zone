"use client";

import { useState, useEffect } from "react";
import { Search, Filter, MoreHorizontal, CheckCircle, Ban, RefreshCw, XCircle, Package } from "lucide-react";
import { adminService } from "@/services/admin";
import { formatDate, userStatusColors } from "@/lib/utils";

export default function UsersPage() {
  const [users, setUsers] = useState<any[]>([]);
  const [total, setTotal] = useState(0);
  const [loading, setLoading] = useState(true);
  const [page, setPage] = useState(1);
  const [search, setSearch] = useState("");
  const [status, setStatus] = useState("all");

  const fetchUsers = async () => {
    setLoading(true);
    try {
      const res = await adminService.users.list({ page, limit: 10, search, status });
      setUsers(res.users);
      setTotal(res.total);
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchUsers();
  }, [page, search, status]);

  const handleAction = async (id: string, action: "verify" | "suspend" | "ban" | "restore") => {
    try {
      await adminService.users[action](id);
      fetchUsers();
    } catch (err) {
      console.error(err);
    }
  };

  return (
    <div className="space-y-6 max-w-[1400px]">
      <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4">
        <div>
          <h2 className="text-2xl font-bold text-gray-900">Users</h2>
          <p className="text-sm text-gray-500 mt-1">Manage platform users and their accounts.</p>
        </div>
      </div>

      <div className="admin-card p-4">
        <div className="flex flex-col sm:flex-row justify-between gap-4 mb-4">
          <div className="relative max-w-md w-full">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400 w-4 h-4" />
            <input
              type="text"
              placeholder="Search users by name or location..."
              className="w-full pl-9 pr-4 py-2 text-sm bg-gray-50 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-purple-500/30 focus:border-purple-400"
              value={search}
              onChange={(e) => { setSearch(e.target.value); setPage(1); }}
            />
          </div>
          <div className="flex items-center gap-3">
            <select 
              className="text-sm bg-gray-50 border border-gray-200 rounded-lg px-3 py-2 focus:outline-none focus:ring-2 focus:ring-purple-500/30"
              value={status}
              onChange={(e) => { setStatus(e.target.value); setPage(1); }}
            >
              <option value="all">All Status</option>
              <option value="active">Active</option>
              <option value="suspended">Suspended</option>
              <option value="banned">Banned</option>
            </select>
            <button className="btn-secondary whitespace-nowrap">
              <Filter size={16} /> Filters
            </button>
          </div>
        </div>

        <div className="overflow-x-auto">
          {loading ? (
             <div className="flex justify-center py-10"><div className="w-6 h-6 border-2 border-purple-500 border-t-transparent rounded-full animate-spin"></div></div>
          ) : (
            <table className="data-table">
              <thead>
                <tr>
                  <th>User</th>
                  <th>Location</th>
                  <th>Status</th>
                  <th>Joined</th>
                  <th>Stats</th>
                  <th className="text-right">Actions</th>
                </tr>
              </thead>
              <tbody>
                {users.map((user) => (
                  <tr key={user.id}>
                    <td>
                      <div className="flex items-center gap-3">
                        <div className="w-9 h-9 rounded-full bg-purple-100 flex items-center justify-center text-purple-700 font-bold text-sm">
                          {user.name.charAt(0)}
                        </div>
                        <div>
                          <p className="font-medium text-gray-900">{user.name} {user.isVerified && <CheckCircle size={12} className="inline text-blue-500" />}</p>
                          <p className="text-xs text-gray-500">{user.account?.email}</p>
                        </div>
                      </div>
                    </td>
                    <td className="text-gray-600">{user.location}</td>
                    <td>
                      <span className={`badge ${userStatusColors[user.status] || "badge-gray"}`}>
                        {user.status}
                      </span>
                    </td>
                    <td className="text-gray-600">{formatDate(user.createdAt)}</td>
                    <td>
                      <div className="flex gap-3 text-xs text-gray-500">
                        <span title="Products Listed"><Package size={14} className="inline mr-1"/>{user._count?.products || 0}</span>
                        <span title="Rentals"><RefreshCw size={14} className="inline mr-1"/>{user._count?.rentalsAsRenter || 0}</span>
                      </div>
                    </td>
                    <td className="text-right">
                      <div className="flex items-center justify-end gap-2">
                        {user.status !== 'suspended' && (
                          <button onClick={() => handleAction(user.id, "suspend")} className="p-1.5 text-gray-400 hover:text-amber-500 hover:bg-amber-50 rounded-lg transition-colors" title="Suspend">
                            <XCircle size={18} />
                          </button>
                        )}
                        {user.status !== 'banned' && (
                          <button onClick={() => handleAction(user.id, "ban")} className="p-1.5 text-gray-400 hover:text-red-500 hover:bg-red-50 rounded-lg transition-colors" title="Ban">
                            <Ban size={18} />
                          </button>
                        )}
                        {user.status !== 'active' && (
                          <button onClick={() => handleAction(user.id, "restore")} className="p-1.5 text-gray-400 hover:text-green-500 hover:bg-green-50 rounded-lg transition-colors" title="Restore">
                            <CheckCircle size={18} />
                          </button>
                        )}
                        <button className="p-1.5 text-gray-400 hover:text-purple-600 hover:bg-purple-50 rounded-lg transition-colors">
                          <MoreHorizontal size={18} />
                        </button>
                      </div>
                    </td>
                  </tr>
                ))}
                {users.length === 0 && (
                  <tr><td colSpan={6} className="text-center py-10 text-gray-500">No users found.</td></tr>
                )}
              </tbody>
            </table>
          )}
        </div>
        
        {/* Basic Pagination UI */}
        {!loading && total > 0 && (
          <div className="flex justify-between items-center mt-4 text-sm text-gray-500 px-2">
            <span>Showing {(page - 1) * 10 + 1} to {Math.min(page * 10, total)} of {total} users</span>
            <div className="flex gap-2">
              <button disabled={page === 1} onClick={() => setPage(p => p - 1)} className="px-3 py-1 border rounded disabled:opacity-50 hover:bg-gray-50">Prev</button>
              <button disabled={page * 10 >= total} onClick={() => setPage(p => p + 1)} className="px-3 py-1 border rounded disabled:opacity-50 hover:bg-gray-50">Next</button>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}
