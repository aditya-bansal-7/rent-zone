"use client";

import { useState } from "react";
import { Bell, Plus, Send, Archive, Check, Megaphone } from "lucide-react";
import { mockNotifications } from "@/lib/mock-data";
import { formatRelativeTime, cn } from "@/lib/utils";
import type { Notification, NotificationType } from "@/types";

const TYPE_ICON: Record<string, string> = {
  rentalRequest: "📦", rentalApproved: "✅", rentalReturned: "↩️",
  review: "⭐", report: "⚑", system: "⚙️", broadcast: "📢",
};

const TYPE_COLORS: Record<string, string> = {
  rentalRequest: "badge-blue", rentalApproved: "badge-green", rentalReturned: "badge-gray",
  review: "badge-yellow", report: "badge-red", system: "badge-purple", broadcast: "badge-indigo",
};

export default function NotificationsPage() {
  const [notifications, setNotifications] = useState<Notification[]>(mockNotifications);
  const [showBroadcastForm, setShowBroadcastForm] = useState(false);
  const [broadcastForm, setBroadcastForm] = useState({ title: "", content: "", segment: "all" });

  const handleMarkRead = (id: string) => setNotifications((prev) => prev.map((n) => n.id === id ? { ...n, isRead: true } : n));
  const handleArchive = (id: string) => setNotifications((prev) => prev.map((n) => n.id === id ? { ...n, isArchived: true } : n));
  const handleSendBroadcast = () => {
    if (!broadcastForm.title || !broadcastForm.content) return;
    const newNotif: Notification = {
      id: `n${Date.now()}`, title: broadcastForm.title, content: broadcastForm.content,
      type: "broadcast", isRead: false, isArchived: false, isBroadcast: true,
      targetSegment: broadcastForm.segment, createdAt: new Date().toISOString(),
    };
    setNotifications((prev) => [newNotif, ...prev]);
    setBroadcastForm({ title: "", content: "", segment: "all" });
    setShowBroadcastForm(false);
  };

  const active = notifications.filter((n) => !n.isArchived);
  const unread = active.filter((n) => !n.isRead);

  return (
    <div className="space-y-5 max-w-[900px]">
      <div className="flex items-center justify-between">
        <div>
          <h2 className="text-xl font-bold text-gray-900">Notifications</h2>
          <p className="text-sm text-gray-500">{unread.length} unread · {active.length} active</p>
        </div>
        <button onClick={() => setShowBroadcastForm(true)} className="btn-primary">
          <Megaphone size={15} /> Send Broadcast
        </button>
      </div>

      {/* Broadcast Form */}
      {showBroadcastForm && (
        <div className="admin-card p-5 border-purple-200 bg-purple-50/40">
          <p className="font-semibold text-gray-800 mb-4 flex items-center gap-2">
            <Megaphone size={16} className="text-purple-600" /> New Broadcast Notification
          </p>
          <div className="space-y-3">
            <div>
              <label className="block text-xs font-medium text-gray-600 mb-1">Title</label>
              <input type="text" value={broadcastForm.title} onChange={(e) => setBroadcastForm((p) => ({ ...p, title: e.target.value }))} className="form-input" placeholder="Notification title..." />
            </div>
            <div>
              <label className="block text-xs font-medium text-gray-600 mb-1">Message</label>
              <textarea rows={3} value={broadcastForm.content} onChange={(e) => setBroadcastForm((p) => ({ ...p, content: e.target.value }))} className="form-input resize-none" placeholder="Notification content..." />
            </div>
            <div className="flex gap-3 items-end">
              <div className="flex-1">
                <label className="block text-xs font-medium text-gray-600 mb-1">Target Segment</label>
                <select value={broadcastForm.segment} onChange={(e) => setBroadcastForm((p) => ({ ...p, segment: e.target.value }))} className="form-select">
                  <option value="all">All Users</option>
                  <option value="verified">Verified Only</option>
                  <option value="unverified">Unverified Only</option>
                  <option value="renters">Active Renters</option>
                  <option value="sellers">Active Sellers</option>
                </select>
              </div>
              <div className="flex gap-2">
                <button onClick={handleSendBroadcast} className="btn-primary py-2 gap-1.5"><Send size={14} /> Send</button>
                <button onClick={() => setShowBroadcastForm(false)} className="btn-secondary py-2">Cancel</button>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* Notification List */}
      <div className="admin-card overflow-hidden">
        <div className="divide-y divide-gray-50">
          {active.map((notif) => (
            <div key={notif.id} className={cn("px-5 py-4 hover:bg-gray-50/60 transition-colors", !notif.isRead && "bg-purple-50/30")}>
              <div className="flex items-start gap-4">
                <div className="text-xl flex-shrink-0 w-8 text-center">{TYPE_ICON[notif.type] ?? "🔔"}</div>
                <div className="flex-1 min-w-0">
                  <div className="flex items-start justify-between gap-2">
                    <div className="flex items-center gap-2 flex-wrap">
                      <p className={cn("text-sm font-semibold", !notif.isRead ? "text-gray-900" : "text-gray-700")}>{notif.title}</p>
                      <span className={`badge ${TYPE_COLORS[notif.type] ?? "badge-gray"}`}>{notif.type}</span>
                      {notif.isBroadcast && <span className="badge badge-indigo">Broadcast</span>}
                      {!notif.isRead && <span className="w-2 h-2 bg-purple-500 rounded-full" />}
                    </div>
                    <p className="text-xs text-gray-400 flex-shrink-0">{formatRelativeTime(notif.createdAt)}</p>
                  </div>
                  <p className="text-sm text-gray-500 mt-1">{notif.content}</p>
                  {notif.targetSegment && <p className="text-xs text-purple-500 mt-1">→ {notif.targetSegment}</p>}
                </div>
                <div className="flex items-center gap-1 flex-shrink-0">
                  {!notif.isRead && (
                    <button onClick={() => handleMarkRead(notif.id)} className="p-1.5 rounded-lg hover:bg-purple-50 text-gray-400 hover:text-purple-600 transition-colors" title="Mark read">
                      <Check size={14} />
                    </button>
                  )}
                  <button onClick={() => handleArchive(notif.id)} className="p-1.5 rounded-lg hover:bg-gray-100 text-gray-400 transition-colors" title="Archive">
                    <Archive size={14} />
                  </button>
                </div>
              </div>
            </div>
          ))}
        </div>
        {active.length === 0 && (
          <div className="empty-state py-16">
            <div className="empty-state-icon"><Bell size={24} /></div>
            <p className="text-sm font-medium text-gray-600">No active notifications</p>
          </div>
        )}
      </div>
    </div>
  );
}
