"use client";

import { useState } from "react";
import { Search, CheckCircle, XCircle, Flag, AlertTriangle, Shield, MessageSquare } from "lucide-react";
import { mockReports } from "@/lib/mock-data";
import { formatRelativeTime, getInitials, reportStatusColors, cn } from "@/lib/utils";
import type { Report, ReportStatus } from "@/types";

const STATUS_TABS: { value: ReportStatus | "all"; label: string }[] = [
  { value: "all", label: "All Reports" },
  { value: "pending", label: "Pending" },
  { value: "valid", label: "Valid" },
  { value: "invalid", label: "Invalid" },
  { value: "escalated", label: "Escalated" },
];

export default function ReportsPage() {
  const [reports, setReports] = useState<Report[]>(mockReports);
  const [statusTab, setStatusTab] = useState<ReportStatus | "all">("all");
  const [search, setSearch] = useState("");
  const [selectedReport, setSelectedReport] = useState<Report | null>(null);
  const [noteText, setNoteText] = useState("");

  const filtered = reports.filter((r) => {
    const q = search.toLowerCase();
    const matchSearch = r.reporter.name.toLowerCase().includes(q) || r.reason.includes(q) || (r.reportedUser?.name.toLowerCase().includes(q) ?? false);
    const matchStatus = statusTab === "all" || r.status === statusTab;
    return matchSearch && matchStatus;
  });

  const handleAction = (id: string, status: ReportStatus) => {
    setReports((prev) => prev.map((r) => r.id === id ? { ...r, status, moderationNote: noteText || r.moderationNote } : r));
    setSelectedReport((prev) => prev?.id === id ? { ...prev, status } : prev);
  };

  const counts: Record<string, number> = { all: reports.length };
  reports.forEach((r) => { counts[r.status] = (counts[r.status] ?? 0) + 1; });

  return (
    <div className="space-y-5 max-w-[1400px]">
      <div>
        <h2 className="text-xl font-bold text-gray-900">Reports & Moderation</h2>
        <p className="text-sm text-gray-500">Central inbox for all user-submitted reports</p>
      </div>

      {/* Tabs */}
      <div className="flex gap-1">
        {STATUS_TABS.map((tab) => (
          <button key={tab.value} onClick={() => setStatusTab(tab.value)}
            className={cn(
              "flex items-center gap-1.5 px-3.5 py-2 rounded-lg text-sm font-medium transition-colors",
              statusTab === tab.value ? "bg-purple-600 text-white" : "bg-white text-gray-600 border border-gray-200 hover:bg-gray-50"
            )}>
            {tab.label}
            {counts[tab.value] !== undefined && (
              <span className={cn("px-1.5 py-0.5 rounded-full text-xs font-bold", statusTab === tab.value ? "bg-white/20 text-white" : "bg-gray-100 text-gray-500")}>
                {counts[tab.value]}
              </span>
            )}
          </button>
        ))}
      </div>

      <div className="flex gap-4">
        {/* Report List */}
        <div className={cn("flex-1", selectedReport && "max-w-[60%]")}>
          <div className="admin-card p-4 mb-3">
            <div className="relative">
              <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400 w-4 h-4" />
              <input type="text" placeholder="Search by reporter, reason..." value={search} onChange={(e) => setSearch(e.target.value)} className="form-input pl-9" />
            </div>
          </div>
          <div className="space-y-2">
            {filtered.map((report) => (
              <div
                key={report.id}
                onClick={() => setSelectedReport(selectedReport?.id === report.id ? null : report)}
                className={cn(
                  "admin-card p-4 cursor-pointer hover:shadow-card-hover transition-all",
                  selectedReport?.id === report.id && "ring-2 ring-purple-400",
                  report.status === "pending" && "border-l-4 border-l-amber-400"
                )}
              >
                <div className="flex items-start justify-between gap-3">
                  <div className="flex items-start gap-3">
                    <div className="w-9 h-9 rounded-full bg-gradient-to-br from-purple-400 to-violet-500 flex items-center justify-center text-white text-xs font-bold flex-shrink-0">
                      {getInitials(report.reporter.name)}
                    </div>
                    <div>
                      <div className="flex items-center gap-2">
                        <p className="font-medium text-gray-800 text-sm">{report.reporter.name}</p>
                        <span className="text-gray-400 text-xs">reported</span>
                        <p className="font-medium text-gray-800 text-sm">
                          {report.reportedUser?.name ?? report.reportedProduct?.name ?? "Unknown"}
                        </p>
                      </div>
                      <div className="flex items-center gap-2 mt-1.5">
                        <span className="badge badge-red capitalize">{report.reason}</span>
                        <span className={`badge ${reportStatusColors[report.status]}`}>{report.status}</span>
                      </div>
                      {report.description && (
                        <p className="text-xs text-gray-500 mt-1.5 line-clamp-2">{report.description}</p>
                      )}
                    </div>
                  </div>
                  <p className="text-xs text-gray-400 flex-shrink-0">{formatRelativeTime(report.createdAt)}</p>
                </div>
              </div>
            ))}
          </div>
          {filtered.length === 0 && (
            <div className="admin-card empty-state py-16">
              <div className="empty-state-icon"><Flag size={24} /></div>
              <p className="text-sm font-medium text-gray-600">No reports found</p>
            </div>
          )}
        </div>

        {/* Detail Panel */}
        {selectedReport && (
          <div className="admin-card w-80 flex-shrink-0 overflow-y-auto max-h-[700px] animate-slide-in">
            <div className="px-5 py-4 border-b border-gray-50 flex items-center justify-between">
              <p className="font-semibold text-gray-800">Report Detail</p>
              <button onClick={() => setSelectedReport(null)} className="text-gray-400 hover:text-gray-600 text-xl">×</button>
            </div>
            <div className="p-5 space-y-4">
              {/* Reason & Status */}
              <div className="flex items-center gap-2 flex-wrap">
                <span className="badge badge-red capitalize">{selectedReport.reason}</span>
                <span className={`badge ${reportStatusColors[selectedReport.status]}`}>{selectedReport.status}</span>
              </div>

              {/* Parties */}
              <div className="space-y-3">
                <div className="p-3 bg-gray-50 rounded-xl">
                  <p className="text-xs text-gray-400 mb-1">Reporter</p>
                  <div className="flex items-center gap-2">
                    <div className="w-7 h-7 rounded-full bg-purple-100 flex items-center justify-center text-purple-600 text-xs font-bold">
                      {getInitials(selectedReport.reporter.name)}
                    </div>
                    <p className="text-sm font-medium text-gray-800">{selectedReport.reporter.name}</p>
                  </div>
                </div>
                {selectedReport.reportedUser && (
                  <div className="p-3 bg-red-50 rounded-xl">
                    <p className="text-xs text-red-400 mb-1">Reported User</p>
                    <div className="flex items-center gap-2">
                      <div className="w-7 h-7 rounded-full bg-red-100 flex items-center justify-center text-red-600 text-xs font-bold">
                        {getInitials(selectedReport.reportedUser.name)}
                      </div>
                      <p className="text-sm font-medium text-gray-800">{selectedReport.reportedUser.name}</p>
                    </div>
                  </div>
                )}
                {selectedReport.reportedProduct && (
                  <div className="p-3 bg-amber-50 rounded-xl">
                    <p className="text-xs text-amber-500 mb-1">Reported Product</p>
                    <p className="text-sm font-medium text-gray-800">{selectedReport.reportedProduct.name}</p>
                  </div>
                )}
              </div>

              {/* Description */}
              {selectedReport.description && (
                <div>
                  <p className="text-xs text-gray-400 mb-1">Description</p>
                  <p className="text-sm text-gray-700 bg-gray-50 p-3 rounded-xl">{selectedReport.description}</p>
                </div>
              )}

              {/* Note */}
              <div>
                <label className="text-xs font-medium text-gray-500 mb-1 block">Moderation Note</label>
                <textarea
                  value={noteText || selectedReport.moderationNote || ""}
                  onChange={(e) => setNoteText(e.target.value)}
                  rows={3}
                  placeholder="Add internal note..."
                  className="form-input resize-none text-xs"
                />
              </div>

              {/* Actions */}
              <div className="space-y-2 border-t border-gray-100 pt-3">
                <p className="text-xs font-semibold text-gray-500 uppercase tracking-wide">Actions</p>
                <button onClick={() => handleAction(selectedReport.id, "valid")} className="w-full btn-primary py-2 justify-center gap-1.5 text-xs">
                  <CheckCircle size={13} /> Mark Valid
                </button>
                <button onClick={() => handleAction(selectedReport.id, "invalid")} className="w-full btn-secondary py-2 justify-center gap-1.5 text-xs">
                  <XCircle size={13} /> Mark Invalid
                </button>
                <button onClick={() => handleAction(selectedReport.id, "escalated")} className="w-full btn-secondary py-2 justify-center gap-1.5 text-xs text-amber-600 border-amber-200 hover:bg-amber-50">
                  <AlertTriangle size={13} /> Escalate
                </button>
                {selectedReport.reportedUser && (
                  <button className="w-full btn-danger py-2 justify-center gap-1.5 text-xs">
                    <Shield size={13} /> Suspend User
                  </button>
                )}
              </div>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}
