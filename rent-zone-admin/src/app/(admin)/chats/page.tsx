"use client";

import { useState, useEffect } from "react";
import { MessageSquare, Users } from "lucide-react";
import { adminService } from "@/services/admin";
import { formatRelativeTime, getInitials } from "@/lib/utils";

export default function ChatsPage() {
  const [chats, setChats] = useState<any[]>([]);
  const [total, setTotal] = useState(0);
  const [loading, setLoading] = useState(true);
  const [page, setPage] = useState(1);
  const [selectedChat, setSelectedChat] = useState<any>(null);
  const [messages, setMessages] = useState<any[]>([]);
  const [loadingMessages, setLoadingMessages] = useState(false);

  const fetchChats = async () => {
    setLoading(true);
    try {
      const res = await adminService.chats.list({ page, limit: 20 });
      setChats(res.chats);
      setTotal(res.total);
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => { fetchChats(); }, [page]);

  const openChat = async (chat: any) => {
    setSelectedChat(chat);
    setLoadingMessages(true);
    try {
      const msgs = await adminService.chats.getMessages(chat.id);
      setMessages(msgs);
    } catch (err) {
      console.error(err);
    } finally {
      setLoadingMessages(false);
    }
  };

  return (
    <div className="space-y-6">
      <div>
        <h2 className="text-2xl font-bold text-gray-900">Chat Monitoring</h2>
        <p className="text-sm text-gray-500 mt-1">View conversations between users on the platform.</p>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-4 min-h-[600px]">
        {/* Conversation List */}
        <div className="admin-card overflow-hidden">
          <div className="px-4 py-3 border-b border-gray-100">
            <p className="section-title">Conversations ({total})</p>
          </div>
          <div className="overflow-y-auto max-h-[550px]">
            {loading ? (
              <div className="flex justify-center py-10"><div className="w-6 h-6 border-2 border-purple-500 border-t-transparent rounded-full animate-spin"></div></div>
            ) : chats.length === 0 ? (
              <div className="py-10 text-center text-gray-500 text-sm">No conversations found.</div>
            ) : (
              chats.map((chat) => {
                const participants = chat.participants?.map((p: any) => p.user?.name).filter(Boolean).join(" & ");
                return (
                  <button
                    key={chat.id}
                    onClick={() => openChat(chat)}
                    className={`w-full text-left px-4 py-3 border-b border-gray-50 hover:bg-purple-50/50 transition-colors ${selectedChat?.id === chat.id ? 'bg-purple-50' : ''}`}
                  >
                    <div className="flex items-center gap-3">
                      <div className="w-9 h-9 rounded-full bg-gradient-to-br from-purple-400 to-violet-500 flex items-center justify-center text-white text-xs font-bold flex-shrink-0">
                        <Users size={16} />
                      </div>
                      <div className="min-w-0 flex-1">
                        <p className="text-sm font-medium text-gray-900 truncate">{participants || "Unknown"}</p>
                        <p className="text-xs text-gray-400">{chat._count?.messages || 0} messages · {formatRelativeTime(chat.updatedAt)}</p>
                      </div>
                    </div>
                  </button>
                );
              })
            )}
          </div>
        </div>

        {/* Message View */}
        <div className="admin-card lg:col-span-2 overflow-hidden flex flex-col">
          {!selectedChat ? (
            <div className="flex-1 flex items-center justify-center text-gray-400">
              <div className="text-center">
                <MessageSquare size={40} className="mx-auto mb-3 opacity-30" />
                <p className="text-sm">Select a conversation to view messages</p>
              </div>
            </div>
          ) : (
            <>
              <div className="px-5 py-3 border-b border-gray-100 flex items-center gap-3">
                <p className="section-title">
                  {selectedChat.participants?.map((p: any) => p.user?.name).filter(Boolean).join(" & ")}
                </p>
              </div>
              <div className="flex-1 overflow-y-auto px-5 py-4 space-y-3 max-h-[500px]">
                {loadingMessages ? (
                  <div className="flex justify-center py-10"><div className="w-6 h-6 border-2 border-purple-500 border-t-transparent rounded-full animate-spin"></div></div>
                ) : messages.length === 0 ? (
                  <div className="text-center text-gray-400 text-sm py-10">No messages in this conversation.</div>
                ) : (
                  messages.map((msg) => (
                    <div key={msg.id} className="flex gap-3">
                      <div className="w-7 h-7 rounded-full bg-gray-100 flex items-center justify-center text-gray-500 text-[10px] font-bold flex-shrink-0 mt-0.5">
                        {msg.senderId?.slice(-2)?.toUpperCase()}
                      </div>
                      <div className="bg-gray-50 rounded-xl px-4 py-2 max-w-[80%]">
                        <p className="text-sm text-gray-800">{msg.content}</p>
                        <p className="text-[10px] text-gray-400 mt-1">{formatRelativeTime(msg.createdAt)}</p>
                      </div>
                    </div>
                  ))
                )}
              </div>
            </>
          )}
        </div>
      </div>
    </div>
  );
}
