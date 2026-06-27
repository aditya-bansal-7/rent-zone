"use client";

import { useState } from "react";
import { Search, Shield, Filter, ArrowDownToLine, Clock, Calendar } from "lucide-react";
import { mockAuditLogs } from "@/lib/mock-data";
import { formatDateTime, cn } from "@/lib/utils";
import type { AuditLog, AuditAction } from "@/types";

const ACTION_COLORS: Record<string, string> = {
  user: "badge-purple",
  product: "badge-blue",
  rental: "badge-emerald",
  report: "badge-red",
  review: "badge-amber",
  category: "badge-indigo",
  notification: "badge-gray",
  settings: "badge-gray",
};

export default function AuditLogsPage() {
  const [logs] = useState<AuditLog[]>(mockAuditLogs);
  const [search, setSearch] = useState("");
  const [typeFilter, setTypeFilter] = useState("all");

  const filtered = logs.filter((log) => {
    const q = search.toLowerCase();
    const matchSearch = log.adminName.toLowerCase().includes(q) || 
      log.targetName.toLowerCase().includes(q) || 
      log.action.toLowerCase().includes(q) ||
      (log.details?.toLowerCase().includes(q) ?? false);
    
    const matchType = typeFilter === "all" || log.targetType === typeFilter;
    
    return matchSearch && matchType;
  });

  return (
    <div className="space-y-5 max-w-[1200px]">
      <div className="flex items-center justify-between flex-wrap gap-4">
        <div>
          <h2 className="text-xl font-bold text-gray-900">Audit Logs</h2>
          <p className="text-sm text-gray-500">Track all administrative actions across the platform</p>
        </div>
        <button className="btn-secondary text-xs py-2 gap-1.5">
          <ArrowDownToLine size={14} /> Export Logs
        </button>
      </div>

      {/* Filters */}
      <div className="admin-card p-4">
        <div className="flex flex-wrap gap-3 items-center">
          <div className="relative flex-1 min-w-[200px]">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400 w-4 h-4" />
            <input 
              type="text" 
              placeholder="Search by admin, action, or target..." 
              value={search} 
              onChange={(e) => setSearch(e.target.value)} 
              className="form-input pl-9" 
            />
          </div>
          
          <div className="flex items-center gap-2">
            <Filter size={16} className="text-gray-400" />
            <select 
              value={typeFilter} 
              onChange={(e) => setTypeFilter(e.target.value)} 
              className="form-select w-[160px]"
            >
              <option value="all">All Resource Types</option>
              <option value="user">Users</option>
              <option value="product">Products</option>
              <option value="rental">Rentals</option>
              <option value="report">Reports</option>
              <option value="review">Reviews</option>
              <option value="category">Categories</option>
            </select>
          </div>
          
          <div className="flex items-center gap-2">
            <Calendar size={16} className="text-gray-400" />
            <select className="form-select w-[140px]">
              <option value="7d">Last 7 Days</option>
              <option value="30d">Last 30 Days</option>
              <option value="90d">Last 90 Days</option>
              <option value="all">All Time</option>
            </select>
          </div>
        </div>
      </div>

      {/* Logs Table */}
      <div className="admin-card overflow-hidden">
        <div className="overflow-x-auto">
          <table className="data-table">
            <thead>
              <tr>
                <th>Timestamp</th>
                <th>Admin</th>
                <th>Action</th>
                <th>Target</th>
                <th>Details</th>
              </tr>
            </thead>
            <tbody>
              {filtered.map((log) => (
                <tr key={log.id}>
                  <td className="text-xs text-gray-500 whitespace-nowrap">
                    <div className="flex items-center gap-1.5">
                      <Clock size={12} />
                      {formatDateTime(log.createdAt)}
                    </div>
                  </td>
                  <td>
                    <div className="flex items-center gap-2">
                      <div className="w-6 h-6 rounded-full bg-purple-100 flex items-center justify-center text-purple-600 text-[10px] font-bold">
                        {log.adminName.charAt(0)}
                      </div>
                      <span className="text-sm font-medium text-gray-800">{log.adminName}</span>
                    </div>
                  </td>
                  <td>
                    <div className="flex items-center gap-2">
                      <span className={cn("badge", ACTION_COLORS[log.targetType] || "badge-gray")}>
                        {log.targetType.toUpperCase()}
                      </span>
                      <span className="text-sm text-gray-600 capitalize">
                        {log.action.replace(`${log.targetType}_`, "").replace(/_/g, " ")}
                      </span>
                    </div>
                  </td>
                  <td className="text-sm font-medium text-gray-800">
                    {log.targetName}
                    <span className="text-[10px] text-gray-400 ml-1 font-normal block">ID: {log.targetId}</span>
                  </td>
                  <td className="text-xs text-gray-500 max-w-[200px] truncate">
                    {log.details || "—"}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
        
        {filtered.length === 0 && (
          <div className="empty-state py-12">
            <div className="empty-state-icon bg-gray-100 text-gray-400">
              <Shield size={24} />
            </div>
            <p className="text-sm font-medium text-gray-600">No logs found</p>
            <p className="text-xs text-gray-400 mt-1">Try adjusting your search criteria</p>
          </div>
        )}
      </div>
      
      <div className="flex items-center justify-between text-sm text-gray-500">
        <p>Showing {filtered.length} of {logs.length} log entries</p>
      </div>
    </div>
  );
}
